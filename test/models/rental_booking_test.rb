require "test_helper"

class RentalBookingTest < ActiveSupport::TestCase
  def setup
    @booking = RentalBooking.new(
      rental: rentals(:cervelo),
      guest_name: "Test Guest",
      guest_phone: "010-1111-2222",
      start_date: Date.current + 30,
      end_date: Date.current + 32,
      status: "pending"
    )
  end

  # --- Valid record ---

  test "valid booking with required fields" do
    assert @booking.valid?
  end

  # --- Date validations ---

  test "invalid without start_date" do
    @booking.start_date = nil
    assert_not @booking.valid?
    assert_includes @booking.errors[:start_date], "can't be blank"
  end

  test "invalid without end_date" do
    @booking.end_date = nil
    assert_not @booking.valid?
    assert_includes @booking.errors[:end_date], "can't be blank"
  end

  test "end_date must be after start_date" do
    @booking.end_date = @booking.start_date
    assert_not @booking.valid?
    assert_includes @booking.errors[:end_date], "must be after start date"
  end

  test "end_date before start_date is invalid" do
    @booking.end_date = @booking.start_date - 1
    assert_not @booking.valid?
    assert_includes @booking.errors[:end_date], "must be after start date"
  end

  # --- Status enum ---

  test "status pending" do
    @booking.status = "pending"
    assert @booking.pending?
  end

  test "status confirmed" do
    @booking.status = "confirmed"
    assert @booking.confirmed?
  end

  test "status active" do
    @booking.status = "active"
    assert @booking.active?
  end

  test "status returned" do
    @booking.status = "returned"
    assert @booking.returned?
  end

  test "status cancelled" do
    @booking.status = "cancelled"
    assert @booking.cancelled?
  end

  # --- Status labels ---

  test "status_label returns Korean label" do
    @booking.status = "pending"
    assert_equal "대기", @booking.status_label
  end

  test "status_label for confirmed" do
    @booking.status = "confirmed"
    assert_equal "확정", @booking.status_label
  end

  # --- Customer optional ---

  test "customer is optional" do
    @booking.customer = nil
    assert @booking.valid?
  end

  test "can have a customer" do
    @booking.customer = customers(:one)
    assert @booking.valid?
  end

  # --- Total amount calculation ---

  test "total_amount is calculated before save" do
    @booking.save!
    # daily_rate is 50000, 2 days
    assert_equal 100000, @booking.total_amount
  end

  test "total_amount updates when dates change" do
    @booking.save!
    @booking.end_date = @booking.start_date + 3
    @booking.save!
    assert_equal 150000, @booking.total_amount
  end

  # --- Days ---

  test "days returns number of days" do
    assert_equal 2, @booking.days
  end

  test "days returns 0 when dates are nil" do
    @booking.start_date = nil
    assert_equal 0, @booking.days
  end

  # --- Default status ---

  test "default status is pending" do
    booking = RentalBooking.new
    assert_equal "pending", booking.status
  end

  # --- Fixtures ---

  test "fixtures are loaded" do
    pending = rental_bookings(:pending_booking)
    assert_equal "pending", pending.status
    assert_equal "Park Jimin", pending.guest_name

    confirmed = rental_bookings(:confirmed_booking)
    assert_equal "confirmed", confirmed.status
    assert_equal customers(:two), confirmed.customer
  end
end
