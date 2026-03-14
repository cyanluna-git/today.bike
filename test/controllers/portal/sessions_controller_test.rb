require "test_helper"

class Portal::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
  end

  # --- Login page ---

  test "new renders login page" do
    get portal_login_path
    assert_response :ok
  end

  test "new has phone input" do
    get portal_login_path
    assert_select "input[name='phone']"
  end

  test "new has submit button" do
    get portal_login_path
    assert_select "button[type='submit']"
  end

  test "new links header logo to site home" do
    get portal_login_path
    assert_select "a[href='#{root_path}']", text: /Today\.bike/
  end

  test "new redirects to portal root if already logged in" do
    post portal_login_path, params: { phone: @customer.phone }
    get portal_login_path
    assert_redirected_to portal_root_path
  end

  # --- Login ---

  test "create with valid phone logs in and redirects" do
    post portal_login_path, params: { phone: @customer.phone }
    assert_redirected_to portal_root_path
    follow_redirect!
    assert_response :ok
  end

  test "create sets customer_id in session" do
    post portal_login_path, params: { phone: @customer.phone }
    # Verify we can access portal pages after login
    get portal_root_path
    assert_response :ok
  end

  test "create with invalid phone renders login with error" do
    post portal_login_path, params: { phone: "010-0000-0000" }
    assert_response :unprocessable_entity
    assert_select "input[name='phone']"
  end

  test "create with empty phone renders login with error" do
    post portal_login_path, params: { phone: "" }
    assert_response :unprocessable_entity
  end

  # --- Logout ---

  test "destroy clears session and redirects to login" do
    post portal_login_path, params: { phone: @customer.phone }
    delete portal_logout_path
    assert_redirected_to portal_login_path

    # After logout, portal root should redirect to login
    get portal_root_path
    assert_redirected_to portal_login_path
  end

  # --- Kakao callback stub ---

  test "kakao_callback redirects to login when no uid" do
    get portal_auth_kakao_callback_path
    assert_redirected_to portal_login_path
  end

  test "kakao_callback logs in customer with matching kakao_uid" do
    get portal_auth_kakao_callback_path, params: { uid: @customer.kakao_uid }
    assert_redirected_to portal_root_path

    get portal_root_path
    assert_response :ok
  end

  test "kakao_callback redirects to login with unknown uid" do
    get portal_auth_kakao_callback_path, params: { uid: "unknown_uid" }
    assert_redirected_to portal_login_path
  end
end
