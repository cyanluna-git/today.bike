require "test_helper"

class Admin::RentalBookingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @rental = rentals(:cervelo)
    @booking = rental_bookings(:pending_booking)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_rental_rental_bookings_path(@rental)
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_rental_rental_booking_path(@rental, @booking)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_rental_rental_booking_path(@rental)
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_rental_rental_bookings_path(@rental), params: { rental_booking: { start_date: Date.current + 60, end_date: Date.current + 62 } }
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_rental_rental_bookings_path(@rental)
    assert_response :ok
  end

  test "index displays bookings" do
    sign_in @admin_user
    get admin_rental_rental_bookings_path(@rental)
    assert_select "table"
  end

  test "index filters by status" do
    sign_in @admin_user
    get admin_rental_rental_bookings_path(@rental), params: { status: "pending" }
    assert_response :ok
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_rental_rental_booking_path(@rental, @booking)
    assert_response :ok
  end

  test "show displays booking details" do
    sign_in @admin_user
    get admin_rental_rental_booking_path(@rental, @booking)
    assert_match @booking.status_label, response.body
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_rental_rental_booking_path(@rental)
    assert_response :ok
  end

  # --- Create ---

  test "create with valid params creates booking and redirects" do
    sign_in @admin_user

    assert_difference "RentalBooking.count", 1 do
      post admin_rental_rental_bookings_path(@rental), params: {
        rental_booking: {
          guest_name: "New Guest",
          guest_phone: "010-2222-3333",
          start_date: Date.current + 60,
          end_date: Date.current + 62,
          status: "pending"
        }
      }
    end

    booking = RentalBooking.last
    assert_redirected_to admin_rental_rental_booking_path(@rental, booking)
    follow_redirect!
    assert_match "Booking was successfully created", response.body
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "RentalBooking.count" do
      post admin_rental_rental_bookings_path(@rental), params: {
        rental_booking: {
          start_date: Date.current + 60,
          end_date: Date.current + 58
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_rental_rental_booking_path(@rental, @booking)
    assert_response :ok
  end

  # --- Update ---

  test "update with valid params updates booking and redirects" do
    sign_in @admin_user

    patch admin_rental_rental_booking_path(@rental, @booking), params: {
      rental_booking: { status: "confirmed" }
    }

    assert_redirected_to admin_rental_rental_booking_path(@rental, @booking)
    follow_redirect!
    assert_match "Booking was successfully updated", response.body
    assert_equal "confirmed", @booking.reload.status
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_rental_rental_booking_path(@rental, @booking), params: {
      rental_booking: { end_date: @booking.start_date - 1 }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes booking and redirects" do
    sign_in @admin_user

    assert_difference "RentalBooking.count", -1 do
      delete admin_rental_rental_booking_path(@rental, @booking)
    end

    assert_redirected_to admin_rental_rental_bookings_path(@rental)
    follow_redirect!
    assert_match "Booking was successfully deleted", response.body
  end
end
