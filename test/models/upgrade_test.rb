require "test_helper"

class UpgradeTest < ActiveSupport::TestCase
  def setup
    @service_order = service_orders(:overhaul_order)
    @upgrade = Upgrade.new(
      service_order: @service_order,
      component: "wheelset",
      before_brand: "Shimano",
      before_model: "RS510",
      after_brand: "Zipp",
      after_model: "303 Firecrest",
      upgrade_purpose: "lightweight",
      cost: 2000000
    )
  end

  # --- Valid record ---

  test "valid upgrade with all fields" do
    assert @upgrade.valid?
  end

  test "valid upgrade with minimal fields (service_order, component, after_brand, after_model, upgrade_purpose)" do
    u = Upgrade.new(
      service_order: @service_order,
      component: "saddle",
      after_brand: "Fizik",
      after_model: "Argo Vento R1",
      upgrade_purpose: "comfort"
    )
    assert u.valid?
  end

  # --- Associations ---

  test "belongs to service_order" do
    u = upgrades(:wheelset_upgrade)
    assert_equal service_orders(:delivered_order), u.service_order
  end

  test "invalid without service_order" do
    @upgrade.service_order = nil
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:service_order], "must exist"
  end

  test "service_order has many upgrades" do
    order = service_orders(:delivered_order)
    assert_includes order.upgrades, upgrades(:wheelset_upgrade)
  end

  test "destroying service_order destroys associated upgrades" do
    order = service_orders(:delivered_order)
    upgrade_ids = order.upgrades.pluck(:id)
    assert upgrade_ids.any?
    order.destroy
    upgrade_ids.each do |id|
      assert_not Upgrade.exists?(id)
    end
  end

  # --- component validation ---

  test "component is required" do
    @upgrade.component = nil
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:component], "can't be blank"
  end

  test "component must be in BicycleSpec::COMPONENTS" do
    @upgrade.component = "invalid_component"
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:component], "is not included in the list"
  end

  test "component accepts all valid BicycleSpec::COMPONENTS" do
    BicycleSpec::COMPONENTS.each do |comp|
      @upgrade.component = comp
      assert @upgrade.valid?, "Expected '#{comp}' to be valid"
    end
  end

  # --- after_brand and after_model validations ---

  test "after_brand is required" do
    @upgrade.after_brand = nil
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:after_brand], "can't be blank"
  end

  test "after_brand cannot be blank string" do
    @upgrade.after_brand = ""
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:after_brand], "can't be blank"
  end

  test "after_model is required" do
    @upgrade.after_model = nil
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:after_model], "can't be blank"
  end

  test "after_model cannot be blank string" do
    @upgrade.after_model = ""
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:after_model], "can't be blank"
  end

  # --- upgrade_purpose validation ---

  test "upgrade_purpose is required" do
    @upgrade.upgrade_purpose = nil
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:upgrade_purpose], "can't be blank"
  end

  test "upgrade_purpose accepts valid values" do
    %w[lightweight performance aero comfort other].each do |purpose|
      @upgrade.upgrade_purpose = purpose
      assert @upgrade.valid?, "Expected '#{purpose}' to be valid"
    end
  end

  # --- Optional fields ---

  test "before_brand is optional" do
    @upgrade.before_brand = nil
    assert @upgrade.valid?
  end

  test "before_model is optional" do
    @upgrade.before_model = nil
    assert @upgrade.valid?
  end

  test "cost is optional (allows nil)" do
    @upgrade.cost = nil
    assert @upgrade.valid?
  end

  # --- cost validation ---

  test "cost allows zero" do
    @upgrade.cost = 0
    assert @upgrade.valid?
  end

  test "cost must be non-negative" do
    @upgrade.cost = -1
    assert_not @upgrade.valid?
    assert_includes @upgrade.errors[:cost], "must be greater than or equal to 0"
  end

  test "cost allows large Korean won values" do
    @upgrade.cost = 5000000
    assert @upgrade.valid?
  end

  # --- Labels ---

  test "component_label returns Korean label" do
    @upgrade.component = "wheelset"
    assert_equal "휠셋", @upgrade.component_label
  end

  test "purpose_label returns Korean label" do
    @upgrade.upgrade_purpose = "lightweight"
    assert_equal "경량화", @upgrade.purpose_label
  end

  test "purpose_label for performance" do
    @upgrade.upgrade_purpose = "performance"
    assert_equal "성능향상", @upgrade.purpose_label
  end

  test "purpose_label for aero" do
    @upgrade.upgrade_purpose = "aero"
    assert_equal "에어로", @upgrade.purpose_label
  end

  test "purpose_label for comfort" do
    @upgrade.upgrade_purpose = "comfort"
    assert_equal "편안함", @upgrade.purpose_label
  end

  test "purpose_label for other" do
    @upgrade.upgrade_purpose = "other"
    assert_equal "기타", @upgrade.purpose_label
  end

  # --- Scopes ---

  test "ordered scope returns upgrades ordered by created_at desc" do
    upgrades = Upgrade.ordered
    assert upgrades.count > 0
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "wheelset", upgrades(:wheelset_upgrade).component
    assert_equal "groupset", upgrades(:groupset_upgrade).component
    assert_equal "saddle", upgrades(:saddle_upgrade).component
    assert_equal 2000000, upgrades(:wheelset_upgrade).cost
    assert_equal "Zipp", upgrades(:wheelset_upgrade).after_brand
    assert_equal "303 Firecrest", upgrades(:wheelset_upgrade).after_model
  end

  # --- BicycleSpec auto-update callback (#738) ---

  test "after_create upserts bicycle spec with after_brand and after_model" do
    bicycle = @service_order.bicycle

    # Ensure no existing spec for this component
    bicycle.bicycle_specs.where(component: "stem").destroy_all

    upgrade = @service_order.upgrades.create!(
      component: "stem",
      after_brand: "Zipp",
      after_model: "SL Sprint",
      upgrade_purpose: "aero"
    )

    spec = bicycle.bicycle_specs.find_by(component: "stem")
    assert_not_nil spec
    assert_equal "Zipp", spec.brand
    assert_equal "SL Sprint", spec.component_model
  end

  test "after_create updates existing bicycle spec" do
    bicycle = @service_order.bicycle

    # Create an existing spec
    bicycle.bicycle_specs.find_or_create_by!(component: "saddle") do |s|
      s.brand = "OldBrand"
      s.component_model = "OldModel"
    end

    @service_order.upgrades.create!(
      component: "saddle",
      before_brand: "OldBrand",
      before_model: "OldModel",
      after_brand: "Fizik",
      after_model: "Argo Vento R1",
      upgrade_purpose: "comfort"
    )

    spec = bicycle.bicycle_specs.reload.find_by(component: "saddle")
    assert_equal "Fizik", spec.brand
    assert_equal "Argo Vento R1", spec.component_model
  end
end
