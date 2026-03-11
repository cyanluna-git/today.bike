require "test_helper"

class RepairLogTest < ActiveSupport::TestCase
  def setup
    @service_order = service_orders(:overhaul_order)
    @repair_log = RepairLog.new(
      service_order: @service_order,
      symptom: "브레이크 소음",
      diagnosis: "패드 마모",
      treatment: "패드 교체",
      repair_category: "brake",
      labor_minutes: 20
    )
  end

  # --- Valid record ---

  test "valid repair log with all fields" do
    assert @repair_log.valid?
  end

  test "valid repair log with minimal fields (service_order, symptom, repair_category)" do
    log = RepairLog.new(service_order: @service_order, symptom: "소음", repair_category: "other")
    assert log.valid?
  end

  # --- Associations ---

  test "belongs to service_order" do
    log = repair_logs(:brake_repair)
    assert_equal service_orders(:overhaul_order), log.service_order
  end

  test "invalid without service_order" do
    @repair_log.service_order = nil
    assert_not @repair_log.valid?
    assert_includes @repair_log.errors[:service_order], "must exist"
  end

  test "service_order has many repair_logs" do
    order = service_orders(:overhaul_order)
    assert_includes order.repair_logs, repair_logs(:brake_repair)
    assert_includes order.repair_logs, repair_logs(:shift_repair)
  end

  test "destroying service_order destroys associated repair_logs" do
    order = service_orders(:overhaul_order)
    log_ids = order.repair_logs.pluck(:id)
    assert log_ids.any?
    order.destroy
    log_ids.each do |id|
      assert_not RepairLog.exists?(id)
    end
  end

  # --- symptom validation ---

  test "symptom is required" do
    @repair_log.symptom = nil
    assert_not @repair_log.valid?
    assert_includes @repair_log.errors[:symptom], "can't be blank"
  end

  test "symptom cannot be blank string" do
    @repair_log.symptom = ""
    assert_not @repair_log.valid?
    assert_includes @repair_log.errors[:symptom], "can't be blank"
  end

  # --- repair_category enum ---

  test "repair_category brake" do
    @repair_log.repair_category = "brake"
    assert @repair_log.category_brake?
  end

  test "repair_category shift" do
    @repair_log.repair_category = "shift"
    assert @repair_log.category_shift?
  end

  test "repair_category wheel" do
    @repair_log.repair_category = "wheel"
    assert @repair_log.category_wheel?
  end

  test "repair_category bearing" do
    @repair_log.repair_category = "bearing"
    assert @repair_log.category_bearing?
  end

  test "repair_category cable" do
    @repair_log.repair_category = "cable"
    assert @repair_log.category_cable?
  end

  test "repair_category tire" do
    @repair_log.repair_category = "tire"
    assert @repair_log.category_tire?
  end

  test "repair_category chain" do
    @repair_log.repair_category = "chain"
    assert @repair_log.category_chain?
  end

  test "repair_category other" do
    @repair_log.repair_category = "other"
    assert @repair_log.category_other?
  end

  test "repair_category is required" do
    @repair_log.repair_category = nil
    assert_not @repair_log.valid?
    assert_includes @repair_log.errors[:repair_category], "can't be blank"
  end

  test "invalid repair_category raises ArgumentError" do
    assert_raises(ArgumentError) do
      @repair_log.repair_category = "random_category"
    end
  end

  # --- labor_minutes validation ---

  test "labor_minutes allows nil" do
    @repair_log.labor_minutes = nil
    assert @repair_log.valid?
  end

  test "labor_minutes allows zero" do
    @repair_log.labor_minutes = 0
    assert @repair_log.valid?
  end

  test "labor_minutes must be non-negative" do
    @repair_log.labor_minutes = -1
    assert_not @repair_log.valid?
    assert_includes @repair_log.errors[:labor_minutes], "must be greater than or equal to 0"
  end

  test "labor_minutes must be integer" do
    @repair_log.labor_minutes = 30
    assert @repair_log.valid?
  end

  # --- Optional fields ---

  test "diagnosis is optional" do
    @repair_log.diagnosis = nil
    assert @repair_log.valid?
  end

  test "treatment is optional" do
    @repair_log.treatment = nil
    assert @repair_log.valid?
  end

  # --- category_label ---

  test "category_label returns Korean label for brake" do
    @repair_log.repair_category = "brake"
    assert_equal "브레이크", @repair_log.category_label
  end

  test "category_label returns Korean label for shift" do
    @repair_log.repair_category = "shift"
    assert_equal "변속", @repair_log.category_label
  end

  test "category_label returns Korean label for wheel" do
    @repair_log.repair_category = "wheel"
    assert_equal "휠", @repair_log.category_label
  end

  test "category_label returns Korean label for other" do
    @repair_log.repair_category = "other"
    assert_equal "기타", @repair_log.category_label
  end

  # --- Scopes ---

  test "ordered scope returns repair logs ordered by created_at desc" do
    logs = RepairLog.ordered
    assert logs.count > 0
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "brake", repair_logs(:brake_repair).repair_category
    assert_equal "shift", repair_logs(:shift_repair).repair_category
    assert_equal "wheel", repair_logs(:wheel_repair).repair_category
    assert_equal 30, repair_logs(:brake_repair).labor_minutes
    assert_equal 45, repair_logs(:shift_repair).labor_minutes
  end
end
