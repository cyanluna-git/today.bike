require "test_helper"

class Admin::ServiceProgressesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:overhaul_order)
  end

  test "create requires authentication" do
    post admin_service_order_service_progresses_path(@service_order), params: {
      service_progress: { title: "추가 점검이 필요합니다" }
    }

    assert_redirected_to new_admin_user_session_path
  end

  test "create adds manual update without changing status" do
    sign_in @admin_user

    assert_difference "ServiceProgress.count", 1 do
      post admin_service_order_service_progresses_path(@service_order), params: {
        service_progress: {
          title: "추가 점검이 필요합니다",
          note: "크랭크와 BB 상태를 더 확인하고 있습니다.",
          work_summary: "BB 유격과 체결 상태를 재점검 중입니다.",
          cost_summary: "교체가 필요하면 추가 비용을 안내드릴 예정입니다.",
          review_state: "under_review"
        }
      }, as: :turbo_stream
    end

    progress = @service_order.service_progresses.last
    assert_equal "manual_update", progress.entry_type
    assert_equal "received", progress.from_status
    assert_equal "received", progress.to_status
    assert_equal "under_review", progress.review_state
    assert_equal "received", @service_order.reload.status
    assert_response :ok
  end

  test "create with invalid params re-renders progress tab" do
    sign_in @admin_user

    assert_no_difference "ServiceProgress.count" do
      post admin_service_order_service_progresses_path(@service_order), params: {
        service_progress: {
          title: "",
          note: "제목 없이 저장"
        }
      }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_match "Title can", response.body
    assert_match "service_order_tab_progress", response.body
  end
end
