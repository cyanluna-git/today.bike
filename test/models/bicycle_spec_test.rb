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

  # --- CATEGORY_GROUPS constant ---

  test "CATEGORY_GROUPS is frozen" do
    assert BicycleSpec::CATEGORY_GROUPS.frozen?
  end

  test "CATEGORY_GROUPS covers all components" do
    all_grouped = BicycleSpec::CATEGORY_GROUPS.values.flat_map { |g| g[:components] }
    BicycleSpec::COMPONENTS.each do |component|
      assert_includes all_grouped, component, "#{component} is not in any category group"
    end
  end

  # --- #category method ---

  test "category returns :frame_fork for frame" do
    @spec.component = "frame"
    assert_equal :frame_fork, @spec.category
  end

  test "category returns :frame_fork for fork" do
    @spec.component = "fork"
    assert_equal :frame_fork, @spec.category
  end

  test "category returns :drivetrain for groupset" do
    @spec.component = "groupset"
    assert_equal :drivetrain, @spec.category
  end

  test "category returns :drivetrain for cassette" do
    @spec.component = "cassette"
    assert_equal :drivetrain, @spec.category
  end

  test "category returns :wheels for wheelset" do
    @spec.component = "wheelset"
    assert_equal :wheels, @spec.category
  end

  test "category returns :wheels for tire" do
    @spec.component = "tire"
    assert_equal :wheels, @spec.category
  end

  test "category returns :contact_points for handlebar" do
    @spec.component = "handlebar"
    assert_equal :contact_points, @spec.category
  end

  test "category returns :contact_points for saddle" do
    @spec.component = "saddle"
    assert_equal :contact_points, @spec.category
  end

  test "category returns :other for bottle_cage" do
    @spec.component = "bottle_cage"
    assert_equal :other, @spec.category
  end

  test "category returns :other for computer" do
    @spec.component = "computer"
    assert_equal :other, @spec.category
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
