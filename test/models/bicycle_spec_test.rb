require "test_helper"

class BicycleSpecTest < ActiveSupport::TestCase
  def setup
    @bicycle = bicycles(:road_bike)
    @spec = BicycleSpec.new(
      bicycle: @bicycle,
      component: "frame",
      brand: "Specialized",
      component_model: "Tarmac SL7",
      spec_detail: "Size 54, Carbon"
    )
  end

  # --- Valid record ---

  test "valid bicycle_spec with all fields" do
    assert @spec.valid?
  end

  test "valid bicycle_spec without spec_detail" do
    @spec.spec_detail = nil
    assert @spec.valid?
  end

  # --- component validations ---

  test "invalid without component" do
    @spec.component = nil
    assert_not @spec.valid?
    assert_includes @spec.errors[:component], "can't be blank"
  end

  test "invalid with blank component" do
    @spec.component = ""
    assert_not @spec.valid?
    assert_includes @spec.errors[:component], "can't be blank"
  end

  test "invalid with unknown component" do
    @spec.component = "rocket_engine"
    assert_not @spec.valid?
    assert_includes @spec.errors[:component], "is not included in the list"
  end

  test "valid with each known component" do
    BicycleSpec::COMPONENTS.each do |component|
      @spec.component = component
      assert @spec.valid?, "Expected #{component} to be valid"
    end
  end

  # --- brand validations ---

  test "invalid without brand" do
    @spec.brand = nil
    assert_not @spec.valid?
    assert_includes @spec.errors[:brand], "can't be blank"
  end

  test "invalid with blank brand" do
    @spec.brand = ""
    assert_not @spec.valid?
    assert_includes @spec.errors[:brand], "can't be blank"
  end

  # --- component_model validations ---

  test "invalid without component_model" do
    @spec.component_model = nil
    assert_not @spec.valid?
    assert_includes @spec.errors[:component_model], "can't be blank"
  end

  test "invalid with blank component_model" do
    @spec.component_model = ""
    assert_not @spec.valid?
    assert_includes @spec.errors[:component_model], "can't be blank"
  end

  # --- Association: belongs_to bicycle ---

  test "invalid without bicycle" do
    @spec.bicycle = nil
    assert_not @spec.valid?
    assert_includes @spec.errors[:bicycle], "must exist"
  end

  test "belongs to bicycle" do
    assert_equal @bicycle, bicycle_specs(:frame_spec).bicycle
  end

  # --- Association: Bicycle has_many bicycle_specs ---

  test "bicycle has many bicycle_specs" do
    assert_includes @bicycle.bicycle_specs, bicycle_specs(:frame_spec)
    assert_includes @bicycle.bicycle_specs, bicycle_specs(:wheelset_spec)
    assert_includes @bicycle.bicycle_specs, bicycle_specs(:groupset_spec)
  end

  test "destroying bicycle destroys associated specs" do
    bicycle = bicycles(:gravel_bike)
    spec_id = bicycle_specs(:saddle_spec).id
    bicycle.destroy
    assert_not BicycleSpec.exists?(spec_id)
  end

  # --- COMPONENTS constant ---

  test "COMPONENTS includes expected values" do
    %w[frame fork wheelset groupset saddle handlebar seatpost tire pedal].each do |c|
      assert_includes BicycleSpec::COMPONENTS, c
    end
  end

  test "COMPONENTS is frozen" do
    assert BicycleSpec::COMPONENTS.frozen?
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "frame", bicycle_specs(:frame_spec).component
    assert_equal "Specialized", bicycle_specs(:frame_spec).brand
    assert_equal "Tarmac SL7 Expert", bicycle_specs(:frame_spec).component_model

    assert_equal "wheelset", bicycle_specs(:wheelset_spec).component
    assert_equal "Roval", bicycle_specs(:wheelset_spec).brand

    assert_equal "saddle", bicycle_specs(:saddle_spec).component
    assert_equal bicycles(:gravel_bike), bicycle_specs(:saddle_spec).bicycle
  end
end
