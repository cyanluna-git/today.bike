require "test_helper"

class PartsReplacementTest < ActiveSupport::TestCase
  def setup
    @service_order = service_orders(:overhaul_order)
    @parts_replacement = PartsReplacement.new(
      service_order: @service_order,
      component: "chain",
      old_brand: "Shimano",
      old_model: "CN-HG701",
      new_brand: "Shimano",
      new_model: "CN-HG901",
      reason: "체인 늘어남",
      cost: 45000
    )
  end

  # --- Valid record ---

  test "valid parts replacement with all fields" do
    assert @parts_replacement.valid?
  end

  test "valid parts replacement with minimal fields (service_order, component, new_brand, new_model)" do
    pr = PartsReplacement.new(
      service_order: @service_order,
      component: "tire",
      new_brand: "Continental",
      new_model: "GP5000"
    )
    assert pr.valid?
  end

  # --- Associations ---

  test "belongs to service_order" do
    pr = parts_replacements(:chain_replacement)
    assert_equal service_orders(:completed_order), pr.service_order
  end

  test "invalid without service_order" do
    @parts_replacement.service_order = nil
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:service_order], "must exist"
  end

  test "service_order has many parts_replacements" do
    order = service_orders(:completed_order)
    assert_includes order.parts_replacements, parts_replacements(:chain_replacement)
    assert_includes order.parts_replacements, parts_replacements(:cassette_replacement)
  end

  test "destroying service_order destroys associated parts_replacements" do
    order = service_orders(:completed_order)
    pr_ids = order.parts_replacements.pluck(:id)
    assert pr_ids.any?
    order.destroy
    pr_ids.each do |id|
      assert_not PartsReplacement.exists?(id)
    end
  end

  # --- component validation ---

  test "component is required" do
    @parts_replacement.component = nil
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:component], "can't be blank"
  end

  test "component must be in BicycleSpec::COMPONENTS" do
    @parts_replacement.component = "invalid_component"
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:component], "is not included in the list"
  end

  test "component accepts all valid BicycleSpec::COMPONENTS" do
    BicycleSpec::COMPONENTS.each do |comp|
      @parts_replacement.component = comp
      assert @parts_replacement.valid?, "Expected '#{comp}' to be valid"
    end
  end

  # --- new_brand and new_model validations ---

  test "new_brand is required" do
    @parts_replacement.new_brand = nil
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:new_brand], "can't be blank"
  end

  test "new_brand cannot be blank string" do
    @parts_replacement.new_brand = ""
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:new_brand], "can't be blank"
  end

  test "new_model is required" do
    @parts_replacement.new_model = nil
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:new_model], "can't be blank"
  end

  test "new_model cannot be blank string" do
    @parts_replacement.new_model = ""
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:new_model], "can't be blank"
  end

  # --- Optional fields ---

  test "old_brand is optional" do
    @parts_replacement.old_brand = nil
    assert @parts_replacement.valid?
  end

  test "old_model is optional" do
    @parts_replacement.old_model = nil
    assert @parts_replacement.valid?
  end

  test "reason is optional" do
    @parts_replacement.reason = nil
    assert @parts_replacement.valid?
  end

  test "cost is optional (allows nil)" do
    @parts_replacement.cost = nil
    assert @parts_replacement.valid?
  end

  # --- cost validation ---

  test "cost allows zero" do
    @parts_replacement.cost = 0
    assert @parts_replacement.valid?
  end

  test "cost must be non-negative" do
    @parts_replacement.cost = -1
    assert_not @parts_replacement.valid?
    assert_includes @parts_replacement.errors[:cost], "must be greater than or equal to 0"
  end

  test "cost allows large Korean won values" do
    @parts_replacement.cost = 5000000
    assert @parts_replacement.valid?
  end

  # --- component_label ---

  test "component_label returns Korean label for chain" do
    @parts_replacement.component = "chain"
    assert_equal "체인", @parts_replacement.component_label
  end

  test "component_label returns Korean label for cassette" do
    @parts_replacement.component = "cassette"
    assert_equal "카세트", @parts_replacement.component_label
  end

  test "component_label returns Korean label for tire" do
    @parts_replacement.component = "tire"
    assert_equal "타이어", @parts_replacement.component_label
  end

  test "component_label returns Korean label for wheelset" do
    @parts_replacement.component = "wheelset"
    assert_equal "휠셋", @parts_replacement.component_label
  end

  # --- Scopes ---

  test "ordered scope returns parts replacements ordered by created_at desc" do
    prs = PartsReplacement.ordered
    assert prs.count > 0
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "chain", parts_replacements(:chain_replacement).component
    assert_equal "cassette", parts_replacements(:cassette_replacement).component
    assert_equal "tire", parts_replacements(:tire_replacement).component
    assert_equal 45000, parts_replacements(:chain_replacement).cost
    assert_equal 70000, parts_replacements(:cassette_replacement).cost
    assert_equal "Shimano", parts_replacements(:chain_replacement).new_brand
    assert_equal "CN-HG901", parts_replacements(:chain_replacement).new_model
  end
end
