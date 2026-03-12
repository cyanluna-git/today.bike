require "test_helper"

class RentalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rental = rentals(:cervelo)
    @inactive_rental = rentals(:inactive_rental)
  end

  # --- Index ---

  test "index renders successfully" do
    get rentals_path
    assert_response :ok
  end

  test "index page title contains Bike Rental" do
    get rentals_path
    assert_select "title", text: /Bike Rental/
  end

  test "index shows active rentals" do
    get rentals_path
    assert_match @rental.name, response.body
  end

  test "index does not show inactive rentals" do
    get rentals_path
    assert_no_match @inactive_rental.name, response.body
  end

  test "index shows type badges" do
    get rentals_path
    assert_match @rental.rental_type_label, response.body
  end

  test "index filters by type" do
    get rentals_path, params: { rental_type: "road" }
    assert_response :ok
    assert_match @rental.name, response.body
  end

  test "index type filter excludes other types" do
    get rentals_path, params: { rental_type: "gravel" }
    assert_response :ok
    assert_no_match @rental.name, response.body
  end

  test "index has type filter tabs" do
    get rentals_path
    assert_select "nav[aria-label='Type filter']"
    assert_select "a", text: "All"
  end

  test "index shows daily rate" do
    get rentals_path
    assert_match "50,000", response.body
  end

  # --- Show ---

  test "show renders successfully for active rental" do
    get rental_path(@rental)
    assert_response :ok
  end

  test "show displays rental name" do
    get rental_path(@rental)
    assert_match @rental.name, response.body
  end

  test "show displays rental type badge" do
    get rental_path(@rental)
    assert_match @rental.rental_type_label, response.body
  end

  test "show displays daily rate" do
    get rental_path(@rental)
    assert_match "50,000", response.body
  end

  test "show has booking form" do
    get rental_path(@rental)
    assert_select "form"
    assert_select "input[name='rental_booking[guest_name]']"
    assert_select "input[name='rental_booking[guest_phone]']"
    assert_select "input[name='rental_booking[start_date]']"
    assert_select "input[name='rental_booking[end_date]']"
  end

  test "show has back to rentals link" do
    get rental_path(@rental)
    assert_select "a[href='#{rentals_path}']", text: /Back to Rentals/
  end

  test "show returns 404 for inactive rental" do
    get rental_path(@inactive_rental)
    assert_response :not_found
  end

  # --- Create Booking ---

  test "create_booking creates a pending booking and redirects to confirmation" do
    assert_difference "RentalBooking.count", 1 do
      post create_booking_rental_path(@rental), params: {
        rental_booking: {
          guest_name: "Test User",
          guest_phone: "010-5555-5555",
          start_date: Date.current + 50,
          end_date: Date.current + 52
        }
      }
    end

    booking = RentalBooking.last
    assert_equal "pending", booking.status
    assert_equal "Test User", booking.guest_name
    assert_redirected_to booking_confirmation_rental_path(@rental)
  end

  test "create_booking with invalid data re-renders show" do
    assert_no_difference "RentalBooking.count" do
      post create_booking_rental_path(@rental), params: {
        rental_booking: {
          guest_name: "Test User",
          guest_phone: "010-5555-5555",
          start_date: Date.current + 52,
          end_date: Date.current + 50
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Booking Confirmation ---

  test "booking_confirmation renders successfully" do
    get booking_confirmation_rental_path(@rental)
    assert_response :ok
  end

  test "booking_confirmation shows confirmation message" do
    get booking_confirmation_rental_path(@rental)
    assert_match "예약이 접수되었습니다", response.body
    assert_match "확인 후 연락드리겠습니다", response.body
  end

  test "booking_confirmation has back to rentals link" do
    get booking_confirmation_rental_path(@rental)
    assert_select "a[href='#{rentals_path}']", text: /Back to Rentals/
  end
end
