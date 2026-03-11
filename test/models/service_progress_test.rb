require "test_helper"

class ServiceProgressTest < ActiveSupport::TestCase
  def setup
    @service_order = service_orders(:overhaul_order)
    @progress = ServiceProgress.new(
      service_order: @service_order,
      from_status: "received",
      to_status: "diagnosis"
    )
  end

  # --- Valid record ---

  test "valid with all required fields" do
    assert @progress.valid?
  end

  test "valid with note" do
    @progress.note = "진단 시작"
    assert @progress.valid?
  end

  # --- Validations ---

  test "invalid without service_order" do
    @progress.service_order = nil
    assert_not @progress.valid?
    assert_includes @progress.errors[:service_order], "must exist"
  end

  test "invalid without from_status" do
    @progress.from_status = nil
    assert_not @progress.valid?
    assert_includes @progress.errors[:from_status], "can't be blank"
  end

  test "invalid without to_status" do
    @progress.to_status = nil
    assert_not @progress.valid?
    assert_includes @progress.errors[:to_status], "can't be blank"
  end

  # --- changed_at auto-set ---

  test "changed_at is auto-set on create" do
    freeze_time do
      @progress.save!
      assert_equal Time.current, @progress.changed_at
    end
  end

  test "changed_at preserves manually set value" do
    custom_time = Time.zone.parse("2026-03-01 10:00:00")
    @progress.changed_at = custom_time
    @progress.save!
    assert_equal custom_time, @progress.changed_at
  end

  # --- Associations ---

  test "belongs to service_order" do
    progress = service_progresses(:repair_received_to_in_progress)
    assert_equal service_orders(:repair_order), progress.service_order
  end

  test "service_order has many service_progresses" do
    order = service_orders(:completed_order)
    assert_equal 2, order.service_progresses.count
    assert_includes order.service_progresses, service_progresses(:completed_received_to_in_progress)
    assert_includes order.service_progresses, service_progresses(:completed_in_progress_to_completed)
  end

  test "destroying service_order destroys associated service_progresses" do
    order = service_orders(:delivered_order)
    progress_ids = order.service_progresses.pluck(:id)
    assert progress_ids.length > 0

    order.destroy

    progress_ids.each do |id|
      assert_not ServiceProgress.exists?(id)
    end
  end

  # --- Scopes ---

  test "chronological scope orders by changed_at ascending" do
    order = service_orders(:delivered_order)
    progresses = order.service_progresses.chronological
    assert_equal "received", progresses.first.from_status
    assert_equal "delivered", progresses.last.to_status
  end

  test "reverse_chronological scope orders by changed_at descending" do
    order = service_orders(:delivered_order)
    progresses = order.service_progresses.reverse_chronological
    assert_equal "delivered", progresses.first.to_status
    assert_equal "received", progresses.last.from_status
  end

  # --- Status labels ---

  test "from_status_label returns Korean label" do
    @progress.from_status = "received"
    assert_equal "접수", @progress.from_status_label
  end

  test "to_status_label returns Korean label" do
    @progress.to_status = "in_progress"
    assert_equal "작업중", @progress.to_status_label
  end

  test "status labels for all statuses" do
    labels = {
      "received" => "접수",
      "diagnosis" => "진단",
      "in_progress" => "작업중",
      "completed" => "완료",
      "delivered" => "출고"
    }

    labels.each do |status, label|
      @progress.from_status = status
      @progress.to_status = status
      assert_equal label, @progress.from_status_label
      assert_equal label, @progress.to_status_label
    end
  end

  # --- Auto-record on ServiceOrder status change ---

  test "changing service_order status creates service_progress automatically" do
    order = service_orders(:overhaul_order)
    assert_equal "received", order.status

    assert_difference "ServiceProgress.count", 1 do
      order.update!(status: "diagnosis")
    end

    progress = order.service_progresses.last
    assert_equal "received", progress.from_status
    assert_equal "diagnosis", progress.to_status
    assert_not_nil progress.changed_at
  end

  test "updating service_order without status change does not create service_progress" do
    order = service_orders(:overhaul_order)

    assert_no_difference "ServiceProgress.count" do
      order.update!(work_note: "Updated note")
    end
  end

  test "multiple status changes create multiple service_progresses" do
    order = service_orders(:overhaul_order)

    assert_difference "ServiceProgress.count", 3 do
      order.update!(status: "diagnosis")
      order.update!(status: "in_progress")
      order.update!(status: "completed")
    end

    progresses = order.service_progresses.chronological
    assert_equal "received", progresses[0].from_status
    assert_equal "diagnosis", progresses[0].to_status
    assert_equal "diagnosis", progresses[1].from_status
    assert_equal "in_progress", progresses[1].to_status
    assert_equal "in_progress", progresses[2].from_status
    assert_equal "completed", progresses[2].to_status
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    progress = service_progresses(:repair_received_to_in_progress)
    assert_equal "received", progress.from_status
    assert_equal "in_progress", progress.to_status
    assert_equal "작업 시작", progress.note
    assert_equal service_orders(:repair_order), progress.service_order

    delivered_progress = service_progresses(:delivered_completed_to_delivered)
    assert_equal "completed", delivered_progress.from_status
    assert_equal "delivered", delivered_progress.to_status
    assert_equal "고객 수령 완료", delivered_progress.note
  end
end
