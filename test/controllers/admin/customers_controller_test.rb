require "test_helper"

class Admin::CustomersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @customer = customers(:one)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_customers_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_customer_path(@customer)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_customer_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_customers_path, params: { customer: { name: "Test", phone: "010-1111-2222" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_customer_path(@customer)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_customer_path(@customer), params: { customer: { name: "Updated" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_customer_path(@customer)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_customers_path
    assert_response :ok
  end

  test "index displays customers in a table" do
    sign_in @admin_user
    get admin_customers_path
    assert_select "table"
    assert_select "td", text: @customer.name
  end

  test "index page title contains Customers" do
    sign_in @admin_user
    get admin_customers_path
    assert_select "title", text: /Customers/
  end

  test "index has New Customer link" do
    sign_in @admin_user
    get admin_customers_path
    assert_select "a[href='#{new_admin_customer_path}']", text: /New Customer/
  end

  # --- Search ---

  test "index has search form" do
    sign_in @admin_user
    get admin_customers_path
    assert_select "input[name='query']"
  end

  test "search by name returns matching customers" do
    sign_in @admin_user
    get admin_customers_path, params: { query: "김철수" }
    assert_response :ok
    assert_select "td", text: "김철수"
    assert_select "td", text: "이영희", count: 0
  end

  test "search by partial name returns matching customers" do
    sign_in @admin_user
    get admin_customers_path, params: { query: "김" }
    assert_response :ok
    assert_select "td", text: "김철수"
  end

  test "search by phone returns matching customers" do
    sign_in @admin_user
    get admin_customers_path, params: { query: "1234" }
    assert_response :ok
    assert_select "td", text: "김철수"
  end

  test "search with no match shows empty state" do
    sign_in @admin_user
    get admin_customers_path, params: { query: "존재하지않는이름" }
    assert_response :ok
    assert_select "td[colspan='5']"
  end

  test "search with blank query returns all customers" do
    sign_in @admin_user
    get admin_customers_path, params: { query: "" }
    assert_response :ok
    assert_select "td", text: "김철수"
    assert_select "td", text: "이영희"
  end

  # --- Turbo Frame ---

  test "index wraps table in turbo frame" do
    sign_in @admin_user
    get admin_customers_path
    assert_select "turbo-frame#customers_table"
  end

  test "search form targets customers_table turbo frame" do
    sign_in @admin_user
    get admin_customers_path
    assert_select "form[data-turbo-frame='customers_table']"
  end

  # --- Pagination ---

  test "index paginates customers" do
    sign_in @admin_user
    # Create enough customers to trigger pagination (default 20 per page)
    22.times do |i|
      Customer.create!(name: "Test Customer #{i}", phone: "010-#{format('%04d', i)}-9999")
    end
    get admin_customers_path
    assert_response :ok
    # With 24 total (2 fixtures + 22 created), should have pagination
    assert_select "nav[aria-label='Pagination']"
  end

  test "index page 2 returns second page of customers" do
    sign_in @admin_user
    22.times do |i|
      Customer.create!(name: "Test Customer #{i}", phone: "010-#{format('%04d', i)}-9999")
    end
    get admin_customers_path, params: { page: 2 }
    assert_response :ok
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_customer_path(@customer)
    assert_response :ok
  end

  test "show displays customer details" do
    sign_in @admin_user
    get admin_customer_path(@customer)
    assert_match @customer.name, response.body
    assert_match @customer.phone, response.body
  end

  test "show has edit and delete actions" do
    sign_in @admin_user
    get admin_customer_path(@customer)
    assert_select "a[href='#{edit_admin_customer_path(@customer)}']", text: "Edit"
    assert_select "form[action='#{admin_customer_path(@customer)}']"
  end

  test "show has back to customers link" do
    sign_in @admin_user
    get admin_customer_path(@customer)
    assert_select "a[href='#{admin_customers_path}']", text: /Back to Customers/
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_customer_path
    assert_response :ok
  end

  test "new renders a form" do
    sign_in @admin_user
    get new_admin_customer_path
    assert_select "form"
    assert_select "input[name='customer[name]']"
    assert_select "input[name='customer[phone]']"
  end

  # --- Create ---

  test "create with valid params creates customer and redirects" do
    sign_in @admin_user

    assert_difference "Customer.count", 1 do
      post admin_customers_path, params: {
        customer: { name: "박지민", phone: "010-5555-6666", email: "park@example.com", active: true }
      }
    end

    customer = Customer.last
    assert_redirected_to admin_customer_path(customer)
    follow_redirect!
    assert_match "Customer was successfully created", response.body
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "Customer.count" do
      post admin_customers_path, params: {
        customer: { name: "", phone: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_customer_path(@customer)
    assert_response :ok
  end

  test "edit renders a form with existing values" do
    sign_in @admin_user
    get edit_admin_customer_path(@customer)
    assert_select "input[name='customer[name]'][value='#{@customer.name}']"
  end

  # --- Update ---

  test "update with valid params updates customer and redirects" do
    sign_in @admin_user

    patch admin_customer_path(@customer), params: {
      customer: { name: "Updated Name" }
    }

    assert_redirected_to admin_customer_path(@customer)
    follow_redirect!
    assert_match "Customer was successfully updated", response.body
    assert_equal "Updated Name", @customer.reload.name
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_customer_path(@customer), params: {
      customer: { name: "" }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes customer and redirects to index" do
    sign_in @admin_user

    assert_difference "Customer.count", -1 do
      delete admin_customer_path(@customer)
    end

    assert_redirected_to admin_customers_path
    follow_redirect!
    assert_match "Customer was successfully deleted", response.body
  end
end
