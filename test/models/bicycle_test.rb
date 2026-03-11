require "test_helper"

class BicycleTest < ActiveSupport::TestCase
  def setup
    @customer = customers(:one)
    @bicycle = Bicycle.new(
      brand: "Giant",
      model_label: "TCR Advanced",
      year: 2024,
      frame_number: "GNT2024TCR000001",
      bike_type: "road",
      color: "블루",
      status: "active",
      customer: @customer
    )
  end

  # --- Valid record ---

  test "valid bicycle with all fields" do
    assert @bicycle.valid?
  end

  test "valid bicycle with minimal fields (brand, model_label, customer)" do
    bicycle = Bicycle.new(brand: "Cervelo", model_label: "S5", customer: @customer)
    assert bicycle.valid?
  end

  # --- Brand validations ---

  test "invalid without brand" do
    @bicycle.brand = nil
    assert_not @bicycle.valid?
    assert_includes @bicycle.errors[:brand], "can't be blank"
  end

  test "invalid with blank brand" do
    @bicycle.brand = ""
    assert_not @bicycle.valid?
    assert_includes @bicycle.errors[:brand], "can't be blank"
  end

  # --- model_label validations ---

  test "invalid without model_label" do
    @bicycle.model_label = nil
    assert_not @bicycle.valid?
    assert_includes @bicycle.errors[:model_label], "can't be blank"
  end

  test "invalid with blank model_label" do
    @bicycle.model_label = ""
    assert_not @bicycle.valid?
    assert_includes @bicycle.errors[:model_label], "can't be blank"
  end

  # --- frame_number validations ---

  test "frame_number is optional (nil allowed)" do
    @bicycle.frame_number = nil
    assert @bicycle.valid?
  end

  test "invalid with duplicate frame_number" do
    @bicycle.save!
    duplicate = Bicycle.new(
      brand: "Canyon",
      model_label: "Aeroad",
      frame_number: "GNT2024TCR000001",
      customer: @customer
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:frame_number], "has already been taken"
  end

  test "allows multiple bicycles with nil frame_number" do
    @bicycle.frame_number = nil
    @bicycle.save!
    another = Bicycle.new(
      brand: "Bianchi",
      model_label: "Oltre",
      frame_number: nil,
      customer: @customer
    )
    assert another.valid?
  end

  test "frame_number uniqueness is exact match" do
    @bicycle.save!
    different = Bicycle.new(
      brand: "Cannondale",
      model_label: "SuperSix",
      frame_number: "GNT2024TCR000002",
      customer: @customer
    )
    assert different.valid?
  end

  # --- year is optional ---

  test "year is optional" do
    @bicycle.year = nil
    assert @bicycle.valid?
  end

  # --- color is optional ---

  test "color is optional" do
    @bicycle.color = nil
    assert @bicycle.valid?
  end

  # --- bike_type enum ---

  test "default bike_type is road" do
    bicycle = Bicycle.new(brand: "Trek", model_label: "Madone", customer: @customer)
    assert_equal "road", bicycle.bike_type
  end

  test "bike_type road" do
    @bicycle.bike_type = "road"
    assert @bicycle.road?
  end

  test "bike_type mtb" do
    @bicycle.bike_type = "mtb"
    assert @bicycle.mtb?
  end

  test "bike_type gravel" do
    @bicycle.bike_type = "gravel"
    assert @bicycle.gravel?
  end

  test "bike_type hybrid" do
    @bicycle.bike_type = "hybrid"
    assert @bicycle.hybrid?
  end

  test "bike_type other" do
    @bicycle.bike_type = "other"
    assert @bicycle.other?
  end

  test "invalid bike_type raises ArgumentError" do
    assert_raises(ArgumentError) do
      @bicycle.bike_type = "unicycle"
    end
  end

  # --- status enum ---

  test "default status is active" do
    bicycle = Bicycle.new(brand: "Trek", model_label: "Madone", customer: @customer)
    assert_equal "active", bicycle.status
  end

  test "status active" do
    @bicycle.status = "active"
    assert @bicycle.active?
  end

  test "status sold" do
    @bicycle.status = "sold"
    assert @bicycle.sold?
  end

  test "status scrapped" do
    @bicycle.status = "scrapped"
    assert @bicycle.scrapped?
  end

  test "invalid status raises ArgumentError" do
    assert_raises(ArgumentError) do
      @bicycle.status = "stolen"
    end
  end

  # --- Association: belongs_to customer ---

  test "invalid without customer" do
    @bicycle.customer = nil
    assert_not @bicycle.valid?
    assert_includes @bicycle.errors[:customer], "must exist"
  end

  test "belongs to customer" do
    assert_equal @customer, bicycles(:road_bike).customer
  end

  # --- Association: Customer has_many bicycles ---

  test "customer has many bicycles" do
    assert_includes @customer.bicycles, bicycles(:road_bike)
    assert_includes @customer.bicycles, bicycles(:sold_bike)
  end

  test "destroying customer destroys associated bicycles" do
    customer = customers(:two)
    bicycle_id = bicycles(:gravel_bike).id
    customer.destroy
    assert_not Bicycle.exists?(bicycle_id)
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "Specialized", bicycles(:road_bike).brand
    assert_equal "Tarmac SL7", bicycles(:road_bike).model_label
    assert_equal "road", bicycles(:road_bike).bike_type

    assert_equal "Trek", bicycles(:gravel_bike).brand
    assert_equal "gravel", bicycles(:gravel_bike).bike_type

    assert_equal "sold", bicycles(:sold_bike).status
  end
end
