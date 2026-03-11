require "test_helper"

class BicycleSpecUpdaterTest < ActiveSupport::TestCase
  def setup
    @bicycle = bicycles(:road_bike)
  end

  test "creates new bicycle spec when none exists" do
    @bicycle.bicycle_specs.where(component: "pedal").destroy_all

    spec = BicycleSpecUpdater.upsert_spec(
      bicycle: @bicycle,
      component: "pedal",
      brand: "Shimano",
      component_model: "PD-R9100"
    )

    assert spec.persisted?
    assert_equal "pedal", spec.component
    assert_equal "Shimano", spec.brand
    assert_equal "PD-R9100", spec.component_model
    assert_equal @bicycle.id, spec.bicycle_id
  end

  test "updates existing bicycle spec" do
    existing = @bicycle.bicycle_specs.find_by(component: "wheelset")
    assert_not_nil existing
    original_id = existing.id

    spec = BicycleSpecUpdater.upsert_spec(
      bicycle: @bicycle,
      component: "wheelset",
      brand: "Enve",
      component_model: "SES 5.6"
    )

    assert_equal original_id, spec.id
    assert_equal "Enve", spec.brand
    assert_equal "SES 5.6", spec.component_model
  end

  test "PartsReplacement after_create triggers spec upsert" do
    service_order = service_orders(:overhaul_order)
    bicycle = service_order.bicycle

    bicycle.bicycle_specs.where(component: "bartape").destroy_all

    service_order.parts_replacements.create!(
      component: "bartape",
      new_brand: "Lizard Skins",
      new_model: "DSP 3.2mm"
    )

    spec = bicycle.bicycle_specs.find_by(component: "bartape")
    assert_not_nil spec
    assert_equal "Lizard Skins", spec.brand
    assert_equal "DSP 3.2mm", spec.component_model
  end

  test "PartsReplacement after_create updates existing spec" do
    service_order = service_orders(:overhaul_order)
    bicycle = service_order.bicycle

    # wheelset spec exists via fixtures
    existing = bicycle.bicycle_specs.find_by(component: "wheelset")
    assert_not_nil existing

    service_order.parts_replacements.create!(
      component: "wheelset",
      old_brand: existing.brand,
      old_model: existing.component_model,
      new_brand: "DT Swiss",
      new_model: "ARC 1100"
    )

    existing.reload
    assert_equal "DT Swiss", existing.brand
    assert_equal "ARC 1100", existing.component_model
  end
end
