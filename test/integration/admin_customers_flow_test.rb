require "test_helper"

class AdminCustomersFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in admin_users(:one)
  end

  test "full CRUD flow: create, view, update, delete a customer" do
    # 1. Visit index
    get admin_customers_path
    assert_response :ok
    assert_select "h1", text: "Customers"

    # 2. Create a new customer
    get new_admin_customer_path
    assert_response :ok
    assert_select "h1", text: "New Customer"

    post admin_customers_path, params: {
      customer: {
        name: "홍길동",
        phone: "010-3333-4444",
        email: "hong@example.com",
        kakao_uid: "kakao_hong",
        memo: "VIP 고객",
        active: true
      }
    }

    customer = Customer.find_by!(name: "홍길동")
    assert_redirected_to admin_customer_path(customer)
    follow_redirect!
    assert_response :ok
    assert_match "홍길동", response.body
    assert_match "010-3333-4444", response.body
    assert_match "hong@example.com", response.body
    assert_match "kakao_hong", response.body
    assert_match "VIP 고객", response.body

    # 3. Edit the customer
    get edit_admin_customer_path(customer)
    assert_response :ok
    assert_select "h1", text: "Edit Customer"

    patch admin_customer_path(customer), params: {
      customer: { name: "홍길동 (수정됨)", memo: "Updated memo" }
    }
    assert_redirected_to admin_customer_path(customer)
    follow_redirect!
    assert_match "홍길동 (수정됨)", response.body
    assert_match "Updated memo", response.body

    # 4. Customer appears in index
    get admin_customers_path
    assert_response :ok
    assert_match "홍길동 (수정됨)", response.body

    # 5. Delete the customer
    assert_difference "Customer.count", -1 do
      delete admin_customer_path(customer)
    end
    assert_redirected_to admin_customers_path
    follow_redirect!
    assert_match "Customer was successfully deleted", response.body
  end

  test "sidebar contains Customers navigation link" do
    get admin_customers_path
    assert_select "aside nav a[href='#{admin_customers_path}']", text: /Customers/
  end

  test "customers index shows active/inactive badges" do
    # Deactivate one customer
    customers(:two).update!(active: false)

    get admin_customers_path
    assert_select "span", text: "Active"
    assert_select "span", text: "Inactive"
  end

  test "creating customer with duplicate phone shows error" do
    post admin_customers_path, params: {
      customer: { name: "Duplicate", phone: customers(:one).phone }
    }
    assert_response :unprocessable_entity
  end

  test "admin customers routes exist" do
    assert_routing({ path: "/admin/customers", method: :get },
                   { controller: "admin/customers", action: "index" })
    assert_routing({ path: "/admin/customers/new", method: :get },
                   { controller: "admin/customers", action: "new" })
    assert_routing({ path: "/admin/customers", method: :post },
                   { controller: "admin/customers", action: "create" })
    assert_routing({ path: "/admin/customers/1", method: :get },
                   { controller: "admin/customers", action: "show", id: "1" })
    assert_routing({ path: "/admin/customers/1/edit", method: :get },
                   { controller: "admin/customers", action: "edit", id: "1" })
    assert_routing({ path: "/admin/customers/1", method: :patch },
                   { controller: "admin/customers", action: "update", id: "1" })
    assert_routing({ path: "/admin/customers/1", method: :delete },
                   { controller: "admin/customers", action: "destroy", id: "1" })
  end
end
