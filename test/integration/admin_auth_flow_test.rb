require "test_helper"

class AdminAuthFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # GET /admin without login → redirect to sign_in
  test "GET /admin without login redirects to admin sign_in" do
    get admin_root_path
    assert_redirected_to new_admin_user_session_path
  end

  # POST sign_in with valid creds → redirect to /admin
  test "POST sign_in with valid credentials redirects to /admin" do
    post admin_user_session_path, params: {
      admin_user: {
        email: admin_users(:one).email,
        password: "password"
      }
    }
    assert_redirected_to admin_root_path
  end

  # POST sign_in with invalid creds → stays on sign_in (422 or redirect back)
  test "POST sign_in with invalid credentials does not redirect to admin" do
    post admin_user_session_path, params: {
      admin_user: {
        email: admin_users(:one).email,
        password: "wrongpassword"
      }
    }
    assert_response :unprocessable_entity
  end

  # GET /admin with logged in admin → 200 with dashboard content
  test "GET /admin with authenticated admin user returns 200 with dashboard content" do
    sign_in admin_users(:one)
    get admin_root_path
    assert_response :ok
    assert_select "h1", text: "Dashboard"
    assert_match admin_users(:one).email, response.body
  end

  # DELETE sign_out → redirects (away from admin — Devise redirects to root or sign_in)
  test "DELETE sign_out redirects away from admin" do
    sign_in admin_users(:one)
    delete destroy_admin_user_session_path
    assert_response :redirect
    assert_not_equal admin_root_path, response.location
  end

  # After sign_out, GET /admin redirects to sign_in again
  test "GET /admin after sign_out redirects to sign_in" do
    sign_in admin_users(:one)
    delete destroy_admin_user_session_path
    get admin_root_path
    assert_redirected_to new_admin_user_session_path
  end
end
