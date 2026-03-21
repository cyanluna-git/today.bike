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

  # --- grouped_specs ---

  test "grouped_specs returns hash grouped by category" do
    road_bike = bicycles(:road_bike)
    grouped = road_bike.grouped_specs
    assert grouped.is_a?(Hash)
    assert grouped.key?(:frame_fork), "Expected :frame_fork category"
    assert grouped.key?(:drivetrain), "Expected :drivetrain category"
    assert grouped.key?(:wheels), "Expected :wheels category"
  end

  test "grouped_specs only includes categories with specs" do
    road_bike = bicycles(:road_bike)
    grouped = road_bike.grouped_specs
    # road_bike has no "other" category specs (bottle_cage, computer, etc.)
    assert_not grouped.key?(:other), "Should not include :other category"
  end

  test "grouped_specs returns empty hash when no specs" do
    sold_bike = bicycles(:sold_bike)
    assert_equal({}, sold_bike.grouped_specs)
  end

  test "grouped_specs preserves category order from CATEGORY_GROUPS" do
    road_bike = bicycles(:road_bike)
    grouped = road_bike.grouped_specs
    keys = grouped.keys
    expected_order = BicycleSpec::CATEGORY_GROUPS.keys.select { |k| grouped.key?(k) }
    assert_equal expected_order, keys
  end

  test "grouped_specs includes label for each category" do
    road_bike = bicycles(:road_bike)
    grouped = road_bike.grouped_specs
    assert_equal "프레임/포크", grouped[:frame_fork][:label]
    assert_equal "구동계", grouped[:drivetrain][:label]
  end

  test "grouped_specs specs within category are sorted by component order" do
    road_bike = bicycles(:road_bike)
    grouped = road_bike.grouped_specs
    # wheels category should have wheelset before tire
    wheel_specs = grouped[:wheels][:specs]
    wheel_components = wheel_specs.map(&:component)
    assert_equal %w[wheelset tire], wheel_components
  end

  # --- Photos (ActiveStorage) ---

  test "can attach photos" do
    @bicycle.save!
    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.png",
      content_type: "image/png"
    )
    assert @bicycle.photos.attached?
    assert_equal 1, @bicycle.photos.count
  end

  test "can attach multiple photos" do
    @bicycle.save!
    2.times do |i|
      @bicycle.photos.attach(
        io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
        filename: "bike_#{i}.png",
        content_type: "image/png"
      )
    end
    assert_equal 2, @bicycle.photos.count
  end

  test "rejects non-image content type" do
    @bicycle.photos.attach(
      io: StringIO.new("not an image"),
      filename: "malware.exe",
      content_type: "application/octet-stream"
    )
    assert_not @bicycle.valid?
    assert_includes @bicycle.errors[:photos], "must be JPEG, PNG, WebP, or HEIC format"
  end

  test "accepts jpeg content type" do
    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.jpg",
      content_type: "image/jpeg"
    )
    assert @bicycle.valid?
  end

  test "accepts webp content type" do
    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.webp",
      content_type: "image/webp"
    )
    assert @bicycle.valid?
  end

  test "photo_thumbnail returns a variant" do
    @bicycle.save!
    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.png",
      content_type: "image/png"
    )
    variant = @bicycle.photo_thumbnail(@bicycle.photos.first)
    assert variant.present?
  end

  # --- Passport token ---

  test "passport_token is auto-generated on create" do
    @bicycle.save!
    assert_not_nil @bicycle.passport_token
    assert @bicycle.passport_token.length > 0
  end

  test "passport_token is unique" do
    @bicycle.save!
    another = Bicycle.create!(brand: "Cervelo", model_label: "S5", customer: @customer)
    assert_not_equal @bicycle.passport_token, another.passport_token
  end

  test "passport_url returns correct URL" do
    @bicycle.save!
    assert_equal "https://todaybike.cyanluna.com/passport/#{@bicycle.passport_token}", @bicycle.passport_url
  end

  test "passport_url returns nil without token" do
    @bicycle.passport_token = nil
    assert_nil @bicycle.passport_url
  end

  test "ensure_passport_token! generates token if missing" do
    @bicycle.save!
    @bicycle.update_columns(passport_token: nil)
    @bicycle.reload
    assert_nil @bicycle.passport_token

    token = @bicycle.ensure_passport_token!
    assert_not_nil token
    assert_equal token, @bicycle.reload.passport_token
  end

  test "ensure_passport_token! does not regenerate existing token" do
    @bicycle.save!
    original_token = @bicycle.passport_token
    @bicycle.ensure_passport_token!
    assert_equal original_token, @bicycle.passport_token
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
