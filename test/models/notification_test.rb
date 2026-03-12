require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  def setup
    @customer = customers(:one)
    @service_order = service_orders(:completed_order)
    @notification = Notification.new(
      customer: @customer,
      service_order: @service_order,
      notification_type: :completion,
      channel: :kakao,
      status: :pending,
      message: "Test message"
    )
  end

  # --- Valid record ---

  test "valid notification with all fields" do
    assert @notification.valid?
  end

  test "valid notification without service_order" do
    @notification.service_order = nil
    assert @notification.valid?
  end

  # --- Associations ---

  test "belongs to customer" do
    notification = notifications(:pending_notification)
    assert_equal customers(:one), notification.customer
  end

  test "belongs to service_order optionally" do
    notification = notifications(:pending_notification)
    assert_equal service_orders(:completed_order), notification.service_order
  end

  # --- Validations ---

  test "invalid without customer" do
    @notification.customer = nil
    assert_not @notification.valid?
  end

  test "invalid without notification_type" do
    @notification.notification_type = nil
    assert_not @notification.valid?
  end

  test "invalid without channel" do
    @notification.channel = nil
    assert_not @notification.valid?
  end

  test "invalid without status" do
    @notification.status = nil
    assert_not @notification.valid?
  end

  test "invalid without message" do
    @notification.message = nil
    assert_not @notification.valid?
  end

  # --- Enums ---

  test "notification_type status_change" do
    @notification.notification_type = :status_change
    assert @notification.status_change?
  end

  test "notification_type completion" do
    @notification.notification_type = :completion
    assert @notification.completion?
  end

  test "notification_type pickup_ready" do
    @notification.notification_type = :pickup_ready
    assert @notification.pickup_ready?
  end

  test "notification_type general" do
    @notification.notification_type = :general
    assert @notification.general?
  end

  test "channel kakao" do
    @notification.channel = :kakao
    assert @notification.kakao?
  end

  test "channel sms" do
    @notification.channel = :sms
    assert @notification.sms?
  end

  test "channel email" do
    @notification.channel = :email
    assert @notification.email?
  end

  test "status pending" do
    @notification.status = :pending
    assert @notification.pending?
  end

  test "status sent" do
    @notification.status = :sent
    assert @notification.sent?
  end

  test "status failed" do
    @notification.status = :failed
    assert @notification.failed?
  end

  test "status skipped" do
    @notification.status = :skipped
    assert @notification.skipped?
  end

  # --- Mark methods ---

  test "mark_sent! updates status and sent_at" do
    @notification.save!
    freeze_time do
      @notification.mark_sent!
      assert @notification.sent?
      assert_equal Time.current, @notification.sent_at
    end
  end

  test "mark_failed! updates status and error_message" do
    @notification.save!
    @notification.mark_failed!("API error")
    assert @notification.failed?
    assert_equal "API error", @notification.error_message
  end

  test "mark_skipped! updates status and error_message" do
    @notification.save!
    @notification.mark_skipped!("No phone number")
    assert @notification.skipped?
    assert_equal "No phone number", @notification.error_message
  end

  # --- Fixtures ---

  test "fixtures are loaded" do
    assert_equal "pending", notifications(:pending_notification).status
    assert_equal "sent", notifications(:sent_notification).status
  end
end
