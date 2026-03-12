require "test_helper"

class NotificationTemplateTest < ActiveSupport::TestCase
  test "render status_change template" do
    result = NotificationTemplate.render(:status_change, {
      customer_name: "김철수",
      bicycle_name: "Specialized Tarmac",
      status: "completed"
    })

    assert_includes result, "김철수님"
    assert_includes result, "Specialized Tarmac"
    assert_includes result, "완료"
  end

  test "render completion template" do
    result = NotificationTemplate.render(:completion, {
      customer_name: "김철수",
      bicycle_name: "Specialized Tarmac"
    })

    assert_includes result, "김철수님"
    assert_includes result, "Specialized Tarmac"
    assert_includes result, "정비가 완료되었습니다"
    assert_includes result, "픽업 가능합니다"
  end

  test "render pickup_ready template" do
    result = NotificationTemplate.render(:pickup_ready, {
      customer_name: "이영희",
      bicycle_name: "Trek Checkpoint"
    })

    assert_includes result, "이영희님"
    assert_includes result, "Trek Checkpoint"
    assert_includes result, "출고 준비가 완료되었습니다"
  end

  test "render with string template key" do
    result = NotificationTemplate.render("completion", {
      customer_name: "Test",
      bicycle_name: "Bike"
    })

    assert_includes result, "Test님"
  end

  test "render raises error for unknown template" do
    assert_raises(ArgumentError) do
      NotificationTemplate.render(:nonexistent, {})
    end
  end

  test "status labels are converted to Korean" do
    result = NotificationTemplate.render(:status_change, {
      customer_name: "Test",
      bicycle_name: "Bike",
      status: "in_progress"
    })

    assert_includes result, "작업중"
    assert_not_includes result, "in_progress"
  end

  test "template_keys returns all template keys" do
    keys = NotificationTemplate.template_keys
    assert_includes keys, :status_change
    assert_includes keys, :completion
    assert_includes keys, :pickup_ready
  end

  test "template_for returns template string" do
    template = NotificationTemplate.template_for(:completion)
    assert_includes template, "{customer_name}"
    assert_includes template, "{bicycle_name}"
  end
end
