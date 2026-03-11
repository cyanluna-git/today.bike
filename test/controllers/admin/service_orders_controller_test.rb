require "test_helper"

class Admin::ServiceOrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:overhaul_order)
    @bicycle = bicycles(:road_bike)
    @customer = customers(:one)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_service_orders_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_service_order_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_service_order_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_service_orders_path, params: { service_order: { bicycle_id: @bicycle.id, service_type: "repair" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_service_order_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_service_order_path(@service_order), params: { service_order: { status: "in_progress" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_service_order_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_response :ok
  end

  test "index displays service orders in a table" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "table"
    assert_select "td", text: /TB-2026-0001/
  end

  test "index page title contains 서비스오더" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "title", text: /서비스오더/
  end

  test "index has New Service Order link" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "a[href='#{new_admin_service_order_path}']", text: /New Service Order/
  end

  test "index shows order_number as link to show page" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "a[href='#{admin_service_order_path(@service_order)}']", text: @service_order.order_number
  end

  test "index shows customer name" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_match @service_order.customer.name, response.body
  end

  test "index shows bicycle info" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_match @service_order.bicycle.brand, response.body
  end

  # --- Filters ---

  test "index has status filter tabs" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "nav[aria-label='Status filter']"
    assert_select "a", text: "All"
    assert_select "a", text: "Received"
    assert_select "a", text: "In Progress"
  end

  test "filter by status returns matching service orders" do
    sign_in @admin_user
    get admin_service_orders_path, params: { status: "received" }
    assert_response :ok
    assert_select "td", text: /TB-2026-0001/
    assert_select "td", text: /TB-2026-0002/, count: 0
  end

  test "filter by status with no match shows empty state" do
    sign_in @admin_user
    get admin_service_orders_path, params: { status: "diagnosis" }
    assert_response :ok
    assert_select "td[colspan='7']"
  end

  # --- Turbo Frame ---

  test "index wraps table in turbo frame" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "turbo-frame#service_orders_table"
  end

  # --- Pagination ---

  test "index paginates service orders" do
    sign_in @admin_user
    22.times do |i|
      ServiceOrder.create!(
        bicycle: @bicycle,
        service_type: "repair",
        status: "received",
        received_at: Time.current
      )
    end
    get admin_service_orders_path
    assert_response :ok
    assert_select "nav[aria-label='Pagination']"
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_response :ok
  end

  test "show displays service order details" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_match @service_order.order_number, response.body
    assert_match @service_order.service_type.titleize, response.body
  end

  test "show displays customer and bicycle links" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "a[href='#{admin_customer_path(@service_order.customer)}']", text: @service_order.customer.name
    assert_select "a[href='#{admin_bicycle_path(@service_order.bicycle)}']"
  end

  test "show displays cost information" do
    sign_in @admin_user
    completed = service_orders(:completed_order)
    get admin_service_order_path(completed)
    assert_match "120,000", response.body
    assert_match "115,000", response.body
  end

  test "show displays notes" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_match @service_order.diagnosis_note, response.body
  end

  test "show has edit and delete actions" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "a[href='#{edit_admin_service_order_path(@service_order)}']", text: "Edit"
    assert_select "form[action='#{admin_service_order_path(@service_order)}']"
  end

  test "show has back to service orders link" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "a[href='#{admin_service_orders_path}']", text: /Back to Service Orders/
  end

  # --- Show: Tab Navigation ---

  test "show has tabs controller" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "[data-controller='tabs']"
  end

  test "show has tab navigation with five tabs" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "nav[aria-label='Service order tabs']"
    assert_select "button[data-tabs-target='tab']", count: 5
  end

  test "show has Korean tab labels" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "button[data-tab-name='basic_info']", text: "기본정보"
    assert_select "button[data-tab-name='progress']", text: "진행상황"
    assert_select "button[data-tab-name='photos']", text: "정비사진"
    assert_select "button[data-tab-name='parts']", text: "부품교체"
    assert_select "button[data-tab-name='repairs']", text: "수리내역"
  end

  test "show has turbo frames for each tab panel" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "turbo-frame#service_order_tab_basic_info"
    assert_select "turbo-frame#service_order_tab_progress"
    assert_select "turbo-frame#service_order_tab_photos"
    assert_select "turbo-frame#service_order_tab_parts"
    assert_select "turbo-frame#service_order_tab_repairs"
  end

  test "show basic_info tab contains service order details" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "turbo-frame#service_order_tab_basic_info" do
      assert_select "dd", text: @service_order.order_number
    end
  end

  test "show placeholder tabs display coming soon" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "turbo-frame#service_order_tab_progress", text: /Coming soon/
    assert_select "turbo-frame#service_order_tab_photos", text: /Coming soon/
    assert_select "turbo-frame#service_order_tab_parts", text: /Coming soon/
    assert_select "turbo-frame#service_order_tab_repairs", text: /Coming soon/
  end

  test "show default tab is basic_info" do
    sign_in @admin_user
    get admin_service_order_path(@service_order)
    assert_select "[data-tabs-default-tab-value='basic_info']"
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_service_order_path
    assert_response :ok
  end

  test "new renders a form with customer and bicycle selects" do
    sign_in @admin_user
    get new_admin_service_order_path
    assert_select "form"
    assert_select "select[name='customer_id']"
    assert_select "select[name='service_order[bicycle_id]']"
    assert_select "select[name='service_order[service_type]']"
  end

  test "new has stimulus controller attributes" do
    sign_in @admin_user
    get new_admin_service_order_path
    assert_select "[data-controller='service-order-form']"
    assert_select "[data-service-order-form-target='customer']"
    assert_select "[data-service-order-form-target='bicycle']"
  end

  test "new pre-fills customer when bicycle_id provided" do
    sign_in @admin_user
    get new_admin_service_order_path(bicycle_id: @bicycle.id)
    assert_response :ok
    assert_select "select[name='customer_id'] option[selected][value='#{@customer.id}']"
  end

  test "new pre-fills customer when customer_id provided" do
    sign_in @admin_user
    get new_admin_service_order_path(customer_id: @customer.id)
    assert_response :ok
    assert_select "select[name='customer_id'] option[selected][value='#{@customer.id}']"
  end

  # --- Create ---

  test "create with valid params creates service order and redirects" do
    sign_in @admin_user

    assert_difference "ServiceOrder.count", 1 do
      post admin_service_orders_path, params: {
        service_order: {
          bicycle_id: @bicycle.id,
          service_type: "repair",
          expected_completion: "2026-04-01",
          estimated_cost: 50000,
          diagnosis_note: "Test diagnosis"
        }
      }
    end

    service_order = ServiceOrder.last
    assert_redirected_to admin_service_order_path(service_order)
    follow_redirect!
    assert_match "Service order was successfully created", response.body
  end

  test "create generates order_number automatically" do
    sign_in @admin_user

    post admin_service_orders_path, params: {
      service_order: {
        bicycle_id: @bicycle.id,
        service_type: "repair"
      }
    }

    service_order = ServiceOrder.last
    assert_match(/\ATB-\d{4}-\d{4}\z/, service_order.order_number)
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "ServiceOrder.count" do
      post admin_service_orders_path, params: {
        service_order: { bicycle_id: nil, service_type: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_service_order_path(@service_order)
    assert_response :ok
  end

  test "edit renders a form with existing values" do
    sign_in @admin_user
    get edit_admin_service_order_path(@service_order)
    assert_select "select[name='service_order[service_type]']"
    assert_select "select[name='service_order[status]']"
  end

  test "edit form shows status field" do
    sign_in @admin_user
    get edit_admin_service_order_path(@service_order)
    assert_select "select[name='service_order[status]']"
  end

  test "edit form shows final cost field" do
    sign_in @admin_user
    get edit_admin_service_order_path(@service_order)
    assert_select "input[name='service_order[final_cost]']"
  end

  # --- Update ---

  test "update with valid params updates service order and redirects" do
    sign_in @admin_user

    patch admin_service_order_path(@service_order), params: {
      service_order: { status: "in_progress", work_note: "작업 시작" }
    }

    assert_redirected_to admin_service_order_path(@service_order)
    follow_redirect!
    assert_match "Service order was successfully updated", response.body
    assert_equal "in_progress", @service_order.reload.status
    assert_equal "작업 시작", @service_order.work_note
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_service_order_path(@service_order), params: {
      service_order: { service_type: "" }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes service order and redirects to index" do
    sign_in @admin_user

    assert_difference "ServiceOrder.count", -1 do
      delete admin_service_order_path(@service_order)
    end

    assert_redirected_to admin_service_orders_path
    follow_redirect!
    assert_match "Service order was successfully deleted", response.body
  end

  # --- Sidebar ---

  test "sidebar has 서비스오더 link" do
    sign_in @admin_user
    get admin_service_orders_path
    assert_select "a[href='#{admin_service_orders_path}']", text: /서비스오더/
  end
end
