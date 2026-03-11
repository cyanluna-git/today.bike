require "test_helper"

class FrameChangeTest < ActiveSupport::TestCase
  def setup
    @service_order = service_orders(:overhaul_order)
    @frame_change = FrameChange.new(
      service_order: @service_order,
      old_frame_brand: "Specialized",
      old_frame_model: "Tarmac SL7",
      new_frame_brand: "Pinarello",
      new_frame_model: "Dogma F",
      new_frame_size: "54",
      transferred_parts: %w[wheelset groupset handlebar],
      reason: "프레임 크랙 발견",
      cost: 5000000
    )
  end

  # --- Valid record ---

  test "valid frame change with all fields" do
    assert @frame_change.valid?
  end

  test "valid frame change with minimal fields (service_order, new_frame_brand, new_frame_model)" do
    fc = FrameChange.new(
      service_order: @service_order,
      new_frame_brand: "Canyon",
      new_frame_model: "Aeroad CFR"
    )
    assert fc.valid?
  end

  # --- Associations ---

  test "belongs to service_order" do
    fc = frame_changes(:frame_change_one)
    assert_equal service_orders(:delivered_order), fc.service_order
  end

  test "invalid without service_order" do
    @frame_change.service_order = nil
    assert_not @frame_change.valid?
    assert_includes @frame_change.errors[:service_order], "must exist"
  end

  test "service_order has many frame_changes" do
    order = service_orders(:delivered_order)
    assert_includes order.frame_changes, frame_changes(:frame_change_one)
  end

  test "destroying service_order destroys associated frame_changes" do
    order = service_orders(:delivered_order)
    fc_ids = order.frame_changes.pluck(:id)
    assert fc_ids.any?
    order.destroy
    fc_ids.each do |id|
      assert_not FrameChange.exists?(id)
    end
  end

  # --- new_frame_brand and new_frame_model validations ---

  test "new_frame_brand is required" do
    @frame_change.new_frame_brand = nil
    assert_not @frame_change.valid?
    assert_includes @frame_change.errors[:new_frame_brand], "can't be blank"
  end

  test "new_frame_brand cannot be blank string" do
    @frame_change.new_frame_brand = ""
    assert_not @frame_change.valid?
    assert_includes @frame_change.errors[:new_frame_brand], "can't be blank"
  end

  test "new_frame_model is required" do
    @frame_change.new_frame_model = nil
    assert_not @frame_change.valid?
    assert_includes @frame_change.errors[:new_frame_model], "can't be blank"
  end

  test "new_frame_model cannot be blank string" do
    @frame_change.new_frame_model = ""
    assert_not @frame_change.valid?
    assert_includes @frame_change.errors[:new_frame_model], "can't be blank"
  end

  # --- Optional fields ---

  test "old_frame_brand is optional" do
    @frame_change.old_frame_brand = nil
    assert @frame_change.valid?
  end

  test "old_frame_model is optional" do
    @frame_change.old_frame_model = nil
    assert @frame_change.valid?
  end

  test "new_frame_size is optional" do
    @frame_change.new_frame_size = nil
    assert @frame_change.valid?
  end

  test "transferred_parts is optional" do
    @frame_change.transferred_parts = nil
    assert @frame_change.valid?
  end

  test "reason is optional" do
    @frame_change.reason = nil
    assert @frame_change.valid?
  end

  test "cost is optional (allows nil)" do
    @frame_change.cost = nil
    assert @frame_change.valid?
  end

  # --- cost validation ---

  test "cost allows zero" do
    @frame_change.cost = 0
    assert @frame_change.valid?
  end

  test "cost must be non-negative" do
    @frame_change.cost = -1
    assert_not @frame_change.valid?
    assert_includes @frame_change.errors[:cost], "must be greater than or equal to 0"
  end

  # --- transferred_parts ---

  test "transferred_parts returns empty array when nil" do
    @frame_change.transferred_parts = nil
    assert_equal [], @frame_change.transferred_parts
  end

  test "transferred_parts stores and retrieves array of component names" do
    @frame_change.transferred_parts = %w[wheelset groupset saddle]
    assert_equal %w[wheelset groupset saddle], @frame_change.transferred_parts
  end

  test "transferred_parts validates components are in BicycleSpec::COMPONENTS" do
    @frame_change.transferred_parts = %w[wheelset invalid_part]
    assert_not @frame_change.valid?
    assert @frame_change.errors[:transferred_parts].any?
  end

  # --- Scopes ---

  test "ordered scope returns frame changes ordered by created_at desc" do
    fcs = FrameChange.ordered
    assert fcs.count > 0
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    fc = frame_changes(:frame_change_one)
    assert_equal "Pinarello", fc.old_frame_brand
    assert_equal "Cervelo", fc.new_frame_brand
    assert_equal "S5", fc.new_frame_model
    assert_equal "54", fc.new_frame_size
    assert_includes fc.transferred_parts, "wheelset"
    assert_includes fc.transferred_parts, "groupset"
    assert_equal 5000000, fc.cost
  end

  # --- after_create callback (#740) ---

  test "after_create updates bicycle brand and model_label" do
    bicycle = @service_order.bicycle
    original_brand = bicycle.brand

    fc = @service_order.frame_changes.create!(
      new_frame_brand: "Canyon",
      new_frame_model: "Aeroad CFR",
      transferred_parts: BicycleSpec::COMPONENTS.reject { |c| c == "frame" }
    )

    bicycle.reload
    assert_equal "Canyon", bicycle.brand
    assert_equal "Aeroad CFR", bicycle.model_label
  end

  test "after_create creates frame bicycle spec" do
    bicycle = @service_order.bicycle
    bicycle.bicycle_specs.where(component: "frame").destroy_all

    fc = @service_order.frame_changes.create!(
      new_frame_brand: "Canyon",
      new_frame_model: "Aeroad CFR",
      transferred_parts: BicycleSpec::COMPONENTS.reject { |c| c == "frame" }
    )

    spec = bicycle.bicycle_specs.reload.find_by(component: "frame")
    assert_not_nil spec
    assert_equal "Canyon", spec.brand
    assert_equal "Aeroad CFR", spec.component_model
  end

  test "after_create destroys specs for non-transferred components" do
    bicycle = @service_order.bicycle

    # Ensure some specs exist
    bicycle.bicycle_specs.find_or_create_by!(component: "wheelset") do |s|
      s.brand = "Roval"
      s.component_model = "Rapide CLX"
    end
    bicycle.bicycle_specs.find_or_create_by!(component: "saddle") do |s|
      s.brand = "Specialized"
      s.component_model = "Power"
    end

    # Only transfer wheelset, not saddle
    fc = @service_order.frame_changes.create!(
      new_frame_brand: "Canyon",
      new_frame_model: "Aeroad CFR",
      transferred_parts: %w[wheelset]
    )

    bicycle.bicycle_specs.reload
    # wheelset should still exist
    assert bicycle.bicycle_specs.exists?(component: "wheelset")
    # frame should exist (newly created)
    assert bicycle.bicycle_specs.exists?(component: "frame")
    # saddle should be destroyed (not transferred)
    assert_not bicycle.bicycle_specs.exists?(component: "saddle")
  end

  test "after_create keeps specs for transferred components" do
    bicycle = @service_order.bicycle

    # Ensure some specs exist
    bicycle.bicycle_specs.find_or_create_by!(component: "groupset") do |s|
      s.brand = "Shimano"
      s.component_model = "Ultegra"
    end
    bicycle.bicycle_specs.find_or_create_by!(component: "handlebar") do |s|
      s.brand = "Zipp"
      s.component_model = "SL-70"
    end

    fc = @service_order.frame_changes.create!(
      new_frame_brand: "Canyon",
      new_frame_model: "Aeroad CFR",
      transferred_parts: %w[groupset handlebar]
    )

    bicycle.bicycle_specs.reload
    assert bicycle.bicycle_specs.exists?(component: "groupset")
    assert bicycle.bicycle_specs.exists?(component: "handlebar")
    assert bicycle.bicycle_specs.exists?(component: "frame")
  end
end
