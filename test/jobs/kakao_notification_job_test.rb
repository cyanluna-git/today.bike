require "test_helper"

class KakaoNotificationJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @notification = notifications(:pending_notification)
  end

  test "perform sends notification and marks as sent" do
    KakaoNotificationJob.perform_now(@notification.id)
    @notification.reload

    assert @notification.sent?
    assert_not_nil @notification.sent_at
  end

  test "perform does nothing for non-existent notification" do
    assert_nothing_raised do
      KakaoNotificationJob.perform_now(999999)
    end
  end

  test "perform does nothing for already sent notification" do
    @notification.update!(status: :sent, sent_at: Time.current)

    KakaoNotificationJob.perform_now(@notification.id)
    # Should not raise or change anything
    assert @notification.reload.sent?
  end

  test "perform does nothing for skipped notification" do
    @notification.update!(status: :skipped)

    KakaoNotificationJob.perform_now(@notification.id)
    assert @notification.reload.skipped?
  end

  test "perform skips notification when customer has no phone" do
    # Create a customer without phone validation for this test
    customer = @notification.customer
    customer.update_columns(phone: "")

    KakaoNotificationJob.perform_now(@notification.id)
    @notification.reload

    assert @notification.skipped?
    assert_includes @notification.error_message, "phone"

    # Restore phone for other tests
    customer.update_columns(phone: "010-1234-5678")
  end

  test "job can be enqueued" do
    assert_enqueued_with(job: KakaoNotificationJob, args: [@notification.id]) do
      KakaoNotificationJob.perform_later(@notification.id)
    end
  end
end
