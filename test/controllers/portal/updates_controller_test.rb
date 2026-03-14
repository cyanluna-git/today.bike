require "test_helper"

class Portal::UpdatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    post portal_login_path, params: { phone: @customer.phone }
  end

  test "index requires authentication" do
    delete portal_logout_path
    get portal_updates_path
    assert_redirected_to portal_login_path
  end

  test "index renders successfully" do
    get portal_updates_path
    assert_response :ok
  end

  test "index shows service progress updates" do
    get portal_updates_path
    assert_match "추가 점검이 필요합니다", response.body
  end

  test "index shows general notifications" do
    get portal_updates_path
    assert_match "일반 안내", response.body
    assert_match "3월 셋째 주 토요일은 샵 행사로 운영 시간이 1시간 단축됩니다.", response.body
  end

  test "index hides non customer visible progress entries" do
    get portal_updates_path
    assert_no_match "고객에게 바로 노출하지 않을 내부 메모입니다.", response.body
  end

  test "index links service related updates to service detail" do
    get portal_updates_path
    assert_select "a[href='#{portal_service_order_path(service_orders(:overhaul_order))}']", minimum: 1
  end

  test "index renders general notifications without self-linking the page" do
    get portal_updates_path
    assert_select "[data-testid='portal-update-item'][data-linked='false']", text: /3월 셋째 주 토요일은 샵 행사로 운영 시간이 1시간 단축됩니다./
  end
end
