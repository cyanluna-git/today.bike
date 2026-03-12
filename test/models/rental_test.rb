require "test_helper"

class RentalTest < ActiveSupport::TestCase
  def setup
    @rental = Rental.new(
      name: "Test Road Bike",
      daily_rate: 50000,
      rental_type: "road"
    )
  end

  # --- Valid record ---

  test "valid rental with required fields" do
    assert @rental.valid?
  end

  # --- Name validation ---

  test "invalid without name" do
    @rental.name = nil
    assert_not @rental.valid?
    assert_includes @rental.errors[:name], "can't be blank"
  end

  # --- Daily rate validation ---

  test "invalid without daily_rate" do
    @rental.daily_rate = nil
    assert_not @rental.valid?
    assert_includes @rental.errors[:daily_rate], "can't be blank"
  end

  test "daily_rate must be positive" do
    @rental.daily_rate = 0
    assert_not @rental.valid?
  end

  # --- Rental type enum ---

  test "rental_type road" do
    @rental.rental_type = "road"
    assert @rental.road?
  end

  test "rental_type mtb" do
    @rental.rental_type = "mtb"
    assert @rental.mtb?
  end

  test "rental_type gravel" do
    @rental.rental_type = "gravel"
    assert @rental.gravel?
  end

  test "rental_type ebike" do
    @rental.rental_type = "ebike"
    assert @rental.ebike?
  end

  test "rental_type other" do
    @rental.rental_type = "other"
    assert @rental.other?
  end

  test "invalid rental_type raises ArgumentError" do
    assert_raises(ArgumentError) do
      @rental.rental_type = "invalid"
    end
  end

  # --- Rental type labels ---

  test "rental_type_label returns Korean label" do
    @rental.rental_type = "road"
    assert_equal "로드", @rental.rental_type_label
  end

  test "rental_type_label for mtb" do
    @rental.rental_type = "mtb"
    assert_equal "MTB", @rental.rental_type_label
  end

  # --- Defaults ---

  test "default active is true" do
    rental = Rental.new(name: "Test", daily_rate: 10000)
    assert_equal true, rental.active
  end

  test "default rental_type is road" do
    rental = Rental.new(name: "Test", daily_rate: 10000)
    assert_equal "road", rental.rental_type
  end

  # --- Scopes ---

  test "active scope returns only active rentals" do
    active = Rental.active
    assert active.all?(&:active?)
  end

  test "by_type scope filters by rental_type" do
    roads = Rental.by_type("road")
    assert roads.all? { |r| r.rental_type == "road" }
  end

  test "by_type scope returns all when blank" do
    assert_equal Rental.count, Rental.by_type(nil).count
  end

  # --- Associations ---

  test "has many rental_bookings" do
    rental = rentals(:cervelo)
    assert rental.rental_bookings.count > 0
  end

  test "destroying rental destroys bookings" do
    rental = rentals(:cervelo)
    booking_count = rental.rental_bookings.count
    assert booking_count > 0

    assert_difference "RentalBooking.count", -booking_count do
      rental.destroy
    end
  end

  # --- Fixtures ---

  test "fixtures are loaded" do
    cervelo = rentals(:cervelo)
    assert_equal "Cervelo Soloist 56cm", cervelo.name
    assert_equal "road", cervelo.rental_type
    assert cervelo.active?

    inactive = rentals(:inactive_rental)
    assert_not inactive.active?
  end
end
