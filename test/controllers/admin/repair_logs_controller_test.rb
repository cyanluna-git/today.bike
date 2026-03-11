require "test_helper"

class Admin::RepairLogsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:overhaul_order)
    @repair_log = repair_logs(:brake_repair)
  end

  # --- Authentication tests ---

  test "create requires authentication" do
    post admin_service_order_repair_logs_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_service_order_repair_log_path(@service_order, @repair_log)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_service_order_repair_log_path(@service_order, @repair_log)
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_service_order_repair_log_path(@service_order, @repair_log)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Create action ---

  test "create with valid params creates repair_log" do
    sign_in @admin_user

    assert_difference "RepairLog.count", 1 do
      post admin_service_order_repair_logs_path(@service_order),
           params: { repair_log: { symptom: "체인 소음", diagnosis: "체인 늘어남", treatment: "체인 교체", repair_category: "chain", labor_minutes: 15 } }
    end

    log = RepairLog.last
    assert_equal "체인 소음", log.symptom
    assert_equal "체인 늘어남", log.diagnosis
    assert_equal "체인 교체", log.treatment
    assert_equal "chain", log.repair_category
    assert_equal 15, log.labor_minutes
    assert_equal @service_order.id, log.service_order_id
  end

  test "create responds with turbo_stream" do
    sign_in @admin_user

    post admin_service_order_repair_logs_path(@service_order),
         params: { repair_log: { symptom: "소음", repair_category: "brake" } },
         as: :turbo_stream

    assert_response :success
  end

  test "create with invalid params does not create repair_log" do
    sign_in @admin_user

    assert_no_difference "RepairLog.count" do
      post admin_service_order_repair_logs_path(@service_order),
           params: { repair_log: { symptom: "", repair_category: "" } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test "create with minimal params (symptom + category)" do
    sign_in @admin_user

    assert_difference "RepairLog.count", 1 do
      post admin_service_order_repair_logs_path(@service_order),
           params: { repair_log: { symptom: "타이어 펑크", repair_category: "tire" } }
    end

    log = RepairLog.last
    assert_equal "타이어 펑크", log.symptom
    assert_equal "tire", log.repair_category
    assert_nil log.diagnosis
    assert_nil log.treatment
    assert_nil log.labor_minutes
  end

  # --- Edit action ---

  test "edit responds with turbo_stream" do
    sign_in @admin_user

    get edit_admin_service_order_repair_log_path(@service_order, @repair_log),
        as: :turbo_stream

    assert_response :success
  end

  # --- Update action ---

  test "update with valid params updates repair_log" do
    sign_in @admin_user

    patch admin_service_order_repair_log_path(@service_order, @repair_log),
          params: { repair_log: { symptom: "수정된 증상", labor_minutes: 60 } }

    @repair_log.reload
    assert_equal "수정된 증상", @repair_log.symptom
    assert_equal 60, @repair_log.labor_minutes
  end

  test "update responds with turbo_stream" do
    sign_in @admin_user

    patch admin_service_order_repair_log_path(@service_order, @repair_log),
          params: { repair_log: { symptom: "수정된 증상" } },
          as: :turbo_stream

    assert_response :success
  end

  test "update with invalid params does not update repair_log" do
    sign_in @admin_user
    original_symptom = @repair_log.symptom

    patch admin_service_order_repair_log_path(@service_order, @repair_log),
          params: { repair_log: { symptom: "" } },
          as: :turbo_stream

    @repair_log.reload
    assert_equal original_symptom, @repair_log.symptom
  end

  # --- Destroy action ---

  test "destroy removes repair_log" do
    sign_in @admin_user

    assert_difference "RepairLog.count", -1 do
      delete admin_service_order_repair_log_path(@service_order, @repair_log)
    end
  end

  test "destroy responds with turbo_stream" do
    sign_in @admin_user

    delete admin_service_order_repair_log_path(@service_order, @repair_log),
           as: :turbo_stream

    assert_response :success
  end

  test "destroy only deletes repair_logs belonging to the service_order" do
    sign_in @admin_user
    other_log = repair_logs(:wheel_repair) # belongs to repair_order, not overhaul_order

    assert_no_difference "RepairLog.count" do
      delete admin_service_order_repair_log_path(@service_order, other_log)
    end

    assert_response :not_found
  end
end
