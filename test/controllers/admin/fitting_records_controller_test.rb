require "test_helper"

class Admin::FittingRecordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @bicycle = bicycles(:road_bike)
    @fitting_record = fitting_records(:first_fitting)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_bicycle_fitting_records_path(@bicycle)
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_bicycle_fitting_record_path(@bicycle)
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_bicycle_fitting_records_path(@bicycle), params: { fitting_record: { saddle_height: 700.0 } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_bicycle_fitting_record_path(@bicycle, @fitting_record), params: { fitting_record: { saddle_height: 730.0 } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_bicycle_fitting_records_path(@bicycle)
    assert_response :ok
  end

  test "index displays fitting records" do
    sign_in @admin_user
    get admin_bicycle_fitting_records_path(@bicycle)
    assert_select "table"
    assert_match "720.0", response.body
  end

  test "index shows comparison when two or more records exist" do
    sign_in @admin_user
    get admin_bicycle_fitting_records_path(@bicycle)
    assert_select "h2", text: /최근 피팅 비교/
  end

  test "index shows no comparison when only one record exists" do
    sign_in @admin_user
    gravel_bike = bicycles(:gravel_bike)
    get admin_bicycle_fitting_records_path(gravel_bike)
    assert_select "h2", { text: /최근 피팅 비교/, count: 0 }
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_response :ok
  end

  test "show displays measurement values with units" do
    sign_in @admin_user
    get admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_match "720.0 mm", response.body
    assert_match "110.0 mm", response.body
  end

  test "show displays service order link when present" do
    sign_in @admin_user
    get admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_match @fitting_record.service_order.order_number, response.body
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_bicycle_fitting_record_path(@bicycle)
    assert_response :ok
  end

  test "new renders a form" do
    sign_in @admin_user
    get new_admin_bicycle_fitting_record_path(@bicycle)
    assert_select "form"
    assert_select "input[name='fitting_record[saddle_height]']"
  end

  # --- Create ---

  test "create with valid params creates fitting record" do
    sign_in @admin_user

    assert_difference "FittingRecord.count", 1 do
      post admin_bicycle_fitting_records_path(@bicycle), params: {
        fitting_record: {
          saddle_height: 725.0,
          saddle_setback: 52.0,
          stem_length: 100.0,
          handlebar_width: 420.0,
          crank_length: 172.5,
          notes: "새 피팅"
        }
      }
    end

    record = FittingRecord.last
    assert_equal 725.0, record.saddle_height
    assert_equal @bicycle.id, record.bicycle_id
    assert_redirected_to admin_bicycle_fitting_record_path(@bicycle, record)
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "FittingRecord.count" do
      post admin_bicycle_fitting_records_path(@bicycle), params: {
        fitting_record: { saddle_height: nil }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create with service_order links correctly" do
    sign_in @admin_user
    service_order = service_orders(:overhaul_order)

    assert_difference "FittingRecord.count", 1 do
      post admin_bicycle_fitting_records_path(@bicycle), params: {
        fitting_record: {
          saddle_height: 710.0,
          service_order_id: service_order.id
        }
      }
    end

    record = FittingRecord.last
    assert_equal service_order.id, record.service_order_id
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_response :ok
  end

  test "edit renders form with existing values" do
    sign_in @admin_user
    get edit_admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    assert_select "form"
    assert_select "input[name='fitting_record[saddle_height]'][value='720.0']"
  end

  # --- Update ---

  test "update with valid params updates record" do
    sign_in @admin_user

    patch admin_bicycle_fitting_record_path(@bicycle, @fitting_record), params: {
      fitting_record: { saddle_height: 730.0, notes: "높이 조정" }
    }

    assert_redirected_to admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    @fitting_record.reload
    assert_equal 730.0, @fitting_record.saddle_height
    assert_equal "높이 조정", @fitting_record.notes
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_bicycle_fitting_record_path(@bicycle, @fitting_record), params: {
      fitting_record: { saddle_height: nil }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy removes fitting record" do
    sign_in @admin_user

    assert_difference "FittingRecord.count", -1 do
      delete admin_bicycle_fitting_record_path(@bicycle, @fitting_record)
    end

    assert_redirected_to admin_bicycle_fitting_records_path(@bicycle)
  end

  test "destroy only removes records belonging to the bicycle" do
    sign_in @admin_user
    other_record = fitting_records(:gravel_fitting)

    assert_no_difference "FittingRecord.count" do
      delete admin_bicycle_fitting_record_path(@bicycle, other_record)
    end

    assert_response :not_found
  end

  # --- Bicycle show page has fitting section ---

  test "bicycle show page displays fitting records section" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_response :ok
    assert_select "h2", text: /피팅기록/
  end

  test "bicycle show page has link to fitting records" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_select "a[href='#{admin_bicycle_fitting_records_path(@bicycle)}']"
  end
end
