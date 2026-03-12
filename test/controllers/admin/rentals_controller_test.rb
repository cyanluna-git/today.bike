require "test_helper"

class Admin::RentalsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @rental = rentals(:cervelo)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_rentals_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_rental_path(@rental)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_rental_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_rentals_path, params: { rental: { name: "Test", daily_rate: 50000 } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_rental_path(@rental)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_rental_path(@rental), params: { rental: { name: "Updated" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_rental_path(@rental)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_rentals_path
    assert_response :ok
  end

  test "index page title contains 대여관리" do
    sign_in @admin_user
    get admin_rentals_path
    assert_select "title", text: /대여관리/
  end

  test "index displays rentals in a table" do
    sign_in @admin_user
    get admin_rentals_path
    assert_select "table"
    assert_match @rental.name, response.body
  end

  test "index has New Rental link" do
    sign_in @admin_user
    get admin_rentals_path
    assert_select "a[href='#{new_admin_rental_path}']", text: /New Rental/
  end

  test "index shows type badge" do
    sign_in @admin_user
    get admin_rentals_path
    assert_match @rental.rental_type_label, response.body
  end

  test "index filters by type" do
    sign_in @admin_user
    get admin_rentals_path, params: { rental_type: "road" }
    assert_response :ok
    assert_match @rental.name, response.body
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_rental_path(@rental)
    assert_response :ok
  end

  test "show displays rental details" do
    sign_in @admin_user
    get admin_rental_path(@rental)
    assert_match @rental.name, response.body
    assert_match @rental.rental_type_label, response.body
  end

  test "show has edit and delete actions" do
    sign_in @admin_user
    get admin_rental_path(@rental)
    assert_select "a[href='#{edit_admin_rental_path(@rental)}']", text: "Edit"
    assert_select "form[action='#{admin_rental_path(@rental)}']"
  end

  test "show has back to rentals link" do
    sign_in @admin_user
    get admin_rental_path(@rental)
    assert_select "a[href='#{admin_rentals_path}']", text: /Back to Rentals/
  end

  test "show has bookings link" do
    sign_in @admin_user
    get admin_rental_path(@rental)
    assert_select "a[href='#{admin_rental_rental_bookings_path(@rental)}']", text: "Bookings"
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_rental_path
    assert_response :ok
  end

  test "new renders a form" do
    sign_in @admin_user
    get new_admin_rental_path
    assert_select "form"
    assert_select "input[name='rental[name]']"
    assert_select "select[name='rental[rental_type]']"
  end

  # --- Create ---

  test "create with valid params creates rental and redirects" do
    sign_in @admin_user

    assert_difference "Rental.count", 1 do
      post admin_rentals_path, params: {
        rental: {
          name: "New Rental Bike",
          daily_rate: 40000,
          rental_type: "gravel"
        }
      }
    end

    rental = Rental.last
    assert_redirected_to admin_rental_path(rental)
    follow_redirect!
    assert_match "Rental was successfully created", response.body
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "Rental.count" do
      post admin_rentals_path, params: {
        rental: { name: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_rental_path(@rental)
    assert_response :ok
  end

  # --- Update ---

  test "update with valid params updates rental and redirects" do
    sign_in @admin_user

    patch admin_rental_path(@rental), params: {
      rental: { name: "Updated Rental" }
    }

    assert_redirected_to admin_rental_path(@rental)
    follow_redirect!
    assert_match "Rental was successfully updated", response.body
    assert_equal "Updated Rental", @rental.reload.name
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_rental_path(@rental), params: {
      rental: { name: "" }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes rental and redirects to index" do
    sign_in @admin_user

    assert_difference "Rental.count", -1 do
      delete admin_rental_path(@rental)
    end

    assert_redirected_to admin_rentals_path
    follow_redirect!
    assert_match "Rental was successfully deleted", response.body
  end

  # --- Sidebar ---

  test "sidebar has 대여관리 link" do
    sign_in @admin_user
    get admin_rentals_path
    assert_select "a[href='#{admin_rentals_path}']", text: /대여관리/
  end
end
