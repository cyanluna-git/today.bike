require "test_helper"

class AdminRoutesTest < ActionDispatch::IntegrationTest
  test "admin root route exists and maps to dashboard#index" do
    assert_routing({ path: "/admin", method: :get }, { controller: "admin/dashboard", action: "index" })
  end

  test "admin user session new route exists" do
    assert_routing({ path: "/admin_users/sign_in", method: :get }, { controller: "devise/sessions", action: "new" })
  end

  test "admin user session create route exists" do
    assert_routing({ path: "/admin_users/sign_in", method: :post }, { controller: "devise/sessions", action: "create" })
  end

  test "admin user session destroy route exists" do
    assert_routing({ path: "/admin_users/sign_out", method: :delete }, { controller: "devise/sessions", action: "destroy" })
  end
end
