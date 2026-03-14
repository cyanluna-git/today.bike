require "test_helper"

class Portal::BicyclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @bicycle = bicycles(:road_bike)
    # Login
    post portal_login_path, params: { phone: @customer.phone }
  end

  # --- Authentication ---

  test "index requires authentication" do
    delete portal_logout_path
    get portal_bicycles_path
    assert_redirected_to portal_login_path
  end

  test "show requires authentication" do
    delete portal_logout_path
    get portal_bicycle_path(@bicycle)
    assert_redirected_to portal_login_path
  end

  # --- Index ---

  test "index renders successfully" do
    get portal_bicycles_path
    assert_response :ok
  end

  test "index shows customer bicycles" do
    get portal_bicycles_path
    assert_match @bicycle.brand, response.body
    assert_match @bicycle.model_label, response.body
  end

  test "index shows portal dashboard summary cards" do
    get portal_bicycles_path
    assert_select "[data-testid='summary-card-active-work']"
    assert_select "[data-testid='summary-card-recent-update']"
    assert_select "[data-testid='summary-card-bicycle-count']"
  end

  test "index links to service orders and fitting records" do
    get portal_bicycles_path
    assert_select "a[href='#{portal_service_orders_path}']", minimum: 1
    assert_select "a[href='#{portal_fitting_records_path}']", minimum: 1
  end

  test "index links to updates center" do
    get portal_bicycles_path
    assert_select "a[href='#{portal_updates_path}']", minimum: 1
  end

  test "index has next action area" do
    get portal_bicycles_path
    assert_select "[data-testid='portal-next-actions']"
  end

  test "index shows recent updates preview" do
    get portal_bicycles_path
    assert_match "최근 업데이트", response.body
    assert_match "추가 점검이 필요합니다", response.body
    assert_match "3월 셋째 주 토요일은 샵 행사로 운영 시간이 1시간 단축됩니다.", response.body
  end

  test "index recent update summary uses latest portal update feed item" do
    freeze_time do
      Notification.create!(
        customer: @customer,
        notification_type: "general",
        channel: "email",
        status: "sent",
        message: "가장 최근 일반 공지입니다.",
        sent_at: Time.current
      )

      get portal_bicycles_path

      assert_select "[data-testid='summary-card-recent-update']", text: /#{Time.current.strftime('%m.%d')}/
      assert_match "가장 최근 일반 공지입니다.", response.body
    end
  end

  test "index does not show expected completion or cost summary" do
    get portal_bicycles_path
    assert_no_match "예상완료일", response.body
    assert_no_match "예상비용", response.body
    assert_no_match "최종비용", response.body
  end

  test "index has bicycle cards" do
    get portal_bicycles_path
    assert_select "[data-testid='bicycle-card']", minimum: 1
  end

  test "index shows lifecycle reminder snippets on bicycle cards" do
    freeze_time do
      get portal_bicycles_path
      assert_select "[data-testid='bicycle-lifecycle-reminder-compact']", minimum: 1
      assert_match "현재 정비가 진행 중입니다.", response.body
    end
  end

  test "index uses stacked mobile bicycle card layout" do
    get portal_bicycles_path

    assert_match "flex flex-col gap-4 sm:flex-row", response.body
    assert_match "mt-4 grid gap-3 text-sm md:grid-cols-2", response.body
    assert_match "grid gap-4 lg:grid-cols-2", response.body
    assert_match "break-keep", response.body
  end

  test "index does not show other customers bicycles" do
    get portal_bicycles_path
    other_bike = bicycles(:gravel_bike)
    # gravel_bike belongs to customer two
    assert_no_match other_bike.frame_number, response.body
  end

  test "index page title contains 포털 홈" do
    get portal_bicycles_path
    assert_select "title", text: /포털 홈/
  end

  test "index shows bike_type badge" do
    get portal_bicycles_path
    assert_match "ROAD", response.body
  end

  # --- Show ---

  test "show renders successfully" do
    get portal_bicycle_path(@bicycle)
    assert_response :ok
  end

  test "show displays bicycle details" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.brand, response.body
    assert_match @bicycle.model_label, response.body
  end

  test "show displays lifecycle reminder card" do
    freeze_time do
      get portal_bicycle_path(@bicycle)
      assert_select "[data-testid='bicycle-lifecycle-reminder']"
      assert_match "정비 이력 보기", response.body
      assert_match "피팅 기록 보기", response.body
    end
  end

  test "show displays year" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.year.to_s, response.body
  end

  test "show displays color" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.color, response.body
  end

  test "show displays frame number" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.frame_number, response.body
  end

  test "show has back link to bicycle list" do
    get portal_bicycle_path(@bicycle)
    assert_select "a[href='#{portal_bicycles_path}']"
  end

  test "show cannot access other customer bicycle" do
    other_bike = bicycles(:gravel_bike)
    get portal_bicycle_path(other_bike)
    assert_response :not_found
  end

  # --- Layout ---

  test "uses portal layout" do
    get portal_bicycles_path
    assert_select "nav[aria-label='Portal navigation']"
  end

  test "portal layout widens on desktop breakpoints" do
    get portal_bicycles_path

    assert_match "lg:max-w-5xl", response.body
  end

  test "portal layout includes skip link and labeled logout button" do
    get portal_bicycles_path

    assert_select "a[href='#portal-main']", text: "본문으로 건너뛰기"
    assert_select "form button[aria-label='로그아웃']"
  end

  test "has bottom navigation with correct items" do
    get portal_bicycles_path
    assert_select "nav[aria-label='Portal navigation']" do
      assert_select "a", text: /내 자전거/
      assert_select "a", text: /정비이력/
      assert_select "a", text: /피팅/
      assert_select "[data-testid='nav-updates']", text: /업데이트/
      assert_select "a[aria-current='page']", minimum: 1
    end
  end

  test "header shows customer name" do
    get portal_bicycles_path
    assert_match @customer.name, response.body
  end

  test "header shows Today.bike logo" do
    get portal_bicycles_path
    assert_match "Today.bike", response.body
  end

  test "index shows empty state for customer without bicycles" do
    customer = Customer.create!(name: "Empty Rider", phone: "010-9999-9999")

    delete portal_logout_path
    post portal_login_path, params: { phone: customer.phone }

    get portal_bicycles_path

    assert_response :ok
    assert_match "등록된 자전거가 아직 없습니다.", response.body
    assert_select "a[href='#{portal_service_orders_path}']", minimum: 1
    assert_select "a[href='#{portal_fitting_records_path}']", minimum: 1
  end
end
