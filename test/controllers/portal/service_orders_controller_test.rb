require "test_helper"

class Portal::ServiceOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @service_order = service_orders(:overhaul_order)
    @completed_order = service_orders(:completed_order)
    # Login
    post portal_login_path, params: { phone: @customer.phone }
  end

  # --- Authentication ---

  test "index requires authentication" do
    delete portal_logout_path
    get portal_service_orders_path
    assert_redirected_to portal_login_path
  end

  test "show requires authentication" do
    delete portal_logout_path
    get portal_service_order_path(@service_order)
    assert_redirected_to portal_login_path
  end

  # --- Index ---

  test "index renders successfully" do
    get portal_service_orders_path
    assert_response :ok
  end

  test "index page title contains 정비이력" do
    get portal_service_orders_path
    assert_select "title", text: /정비이력/
  end

  test "index shows service order cards" do
    get portal_service_orders_path
    assert_select "[data-testid='service-order-card']", minimum: 1
  end

  test "index shows order number" do
    get portal_service_orders_path
    assert_match @service_order.order_number, response.body
  end

  test "index shows status badge" do
    get portal_service_orders_path
    assert_select "[data-testid='status-badge']", minimum: 1
  end

  test "index shows status in Korean" do
    get portal_service_orders_path
    assert_match "접수", response.body
  end

  test "index shows service type in Korean" do
    get portal_service_orders_path
    assert_select "[data-testid='service-type-label']", minimum: 1
    assert_match "오버홀", response.body
  end

  test "index shows bicycle info" do
    get portal_service_orders_path
    assert_match @service_order.bicycle.brand, response.body
  end

  test "index does not show other customer service orders" do
    get portal_service_orders_path
    other_order = service_orders(:repair_order) # belongs to customer two
    assert_no_match other_order.order_number, response.body
  end

  test "index shows cost info for completed orders" do
    get portal_service_orders_path
    assert_match "115,000", response.body
  end

  # --- Show ---

  test "show renders successfully" do
    get portal_service_order_path(@service_order)
    assert_response :ok
  end

  test "show displays order number" do
    get portal_service_order_path(@service_order)
    assert_select "[data-testid='order-number']", text: @service_order.order_number
  end

  test "show displays status badge" do
    get portal_service_order_path(@service_order)
    assert_select "[data-testid='status-badge']", text: /접수/
  end

  test "show displays service type label in Korean" do
    get portal_service_order_path(@service_order)
    assert_select "[data-testid='service-type-label']", text: /오버홀/
  end

  test "show displays bicycle info" do
    get portal_service_order_path(@service_order)
    assert_match @service_order.bicycle.brand, response.body
    assert_match @service_order.bicycle.model_label, response.body
  end

  test "show displays received date" do
    get portal_service_order_path(@service_order)
    assert_match "2026.03.01", response.body
  end

  test "show displays estimated cost" do
    get portal_service_order_path(@service_order)
    assert_match "350,000", response.body
  end

  test "show displays final cost for completed orders" do
    get portal_service_order_path(@completed_order)
    assert_match "115,000", response.body
  end

  test "show does not display diagnosis_note (internal)" do
    get portal_service_order_path(@service_order)
    assert_no_match @service_order.diagnosis_note, response.body
  end

  test "show does not display work_note (internal)" do
    order = service_orders(:repair_order)
    # Login as customer two who owns repair_order
    delete portal_logout_path
    post portal_login_path, params: { phone: customers(:two).phone }
    get portal_service_order_path(order)
    assert_no_match order.work_note, response.body
  end

  test "show has back link to service orders" do
    get portal_service_order_path(@service_order)
    assert_select "a[href='#{portal_service_orders_path}']"
  end

  test "show cannot access other customer service order" do
    other_order = service_orders(:repair_order) # belongs to customer two
    get portal_service_order_path(other_order)
    assert_response :not_found
  end

  test "show displays repair logs" do
    get portal_service_order_path(@service_order)
    assert_select "[data-testid='repair-logs']"
    assert_match "브레이크", response.body
  end

  test "show displays parts replacements for completed order" do
    get portal_service_order_path(@completed_order)
    assert_select "[data-testid='parts-replacements']"
    assert_match "Shimano", response.body
  end

  test "show has turbo stream subscription" do
    get portal_service_order_path(@service_order)
    assert_select "turbo-cable-stream-source"
  end

  # --- Progress timeline ---

  test "show displays progress timeline for completed order" do
    get portal_service_order_path(@completed_order)
    assert_select "[data-testid='progress-timeline']"
  end

  test "show displays customer-facing progress update feed entries" do
    get portal_service_order_path(@service_order)

    assert_select "[data-testid='progress-feed-entry']", minimum: 1
    assert_match "추가 점검이 필요합니다", response.body
    assert_match "검토중", response.body
    assert_match "BB 유격과 크랭크 체결 상태를 추가로 점검 중입니다.", response.body
  end

  test "show displays contextual cost summary from progress feed" do
    get portal_service_order_path(@service_order)

    assert_select "[data-testid='progress-cost-summary']"
    assert_match "교체 필요 시 추가 비용이 발생할 수 있어 확인 후 안내드릴 예정입니다.", response.body
  end

  test "show hides non customer visible progress updates" do
    get portal_service_order_path(@service_order)

    assert_no_match "고객에게 바로 노출하지 않을 내부 메모입니다.", response.body
  end
end
