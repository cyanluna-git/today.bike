require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
  end

  test "index requires authentication" do
    get admin_root_path
    assert_redirected_to new_admin_user_session_path
  end

  test "index renders successfully for authenticated admin" do
    sign_in @admin_user
    get admin_root_path
    assert_response :ok
  end

  test "index uses admin layout" do
    sign_in @admin_user
    get admin_root_path
    assert_select "aside"
    assert_select "nav"
  end

  test "index displays current admin user email in sidebar" do
    sign_in @admin_user
    get admin_root_path
    assert_match @admin_user.email, response.body
  end

  test "index contains logout button pointing to destroy session path" do
    sign_in @admin_user
    get admin_root_path
    assert_select "form[action='#{destroy_admin_user_session_path}']"
  end

  test "index contains Dashboard heading" do
    sign_in @admin_user
    get admin_root_path
    assert_select "h1", text: "Dashboard"
  end

  test "index page title contains Dashboard" do
    sign_in @admin_user
    get admin_root_path
    assert_select "title", text: /Dashboard/
  end
end
