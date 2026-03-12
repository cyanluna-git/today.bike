require "test_helper"

class Portal::FittingRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @fitting_record = fitting_records(:first_fitting)
    # Login
    post portal_login_path, params: { phone: @customer.phone }
  end

  # --- Authentication ---

  test "index requires authentication" do
    delete portal_logout_path
    get portal_fitting_records_path
    assert_redirected_to portal_login_path
  end

  test "show requires authentication" do
    delete portal_logout_path
    get portal_fitting_record_path(@fitting_record)
    assert_redirected_to portal_login_path
  end

  # --- Index ---

  test "index renders successfully" do
    get portal_fitting_records_path
    assert_response :ok
  end

  test "index page title contains 피팅" do
    get portal_fitting_records_path
    assert_select "title", text: /피팅/
  end

  test "index shows fitting records grouped by bicycle" do
    get portal_fitting_records_path
    assert_select "[data-testid='fitting-bicycle-group']", minimum: 1
  end

  test "index shows fitting record cards" do
    get portal_fitting_records_path
    assert_select "[data-testid='fitting-record-card']", minimum: 1
  end

  test "index shows bicycle name in group header" do
    get portal_fitting_records_path
    assert_match "Specialized", response.body
    assert_match "Tarmac SL7", response.body
  end

  test "index shows saddle height" do
    get portal_fitting_records_path
    assert_match "720.0", response.body
  end

  test "index does not show other customer fitting records" do
    get portal_fitting_records_path
    # gravel_fitting belongs to customer two's bike
    assert_no_match "440.0", response.body
  end

  # --- Show ---

  test "show renders successfully" do
    get portal_fitting_record_path(@fitting_record)
    assert_response :ok
  end

  test "show displays bicycle info" do
    get portal_fitting_record_path(@fitting_record)
    assert_match "Specialized", response.body
    assert_match "Tarmac SL7", response.body
  end

  test "show displays recorded date" do
    get portal_fitting_record_path(@fitting_record)
    assert_match "2026.02.01", response.body
  end

  test "show displays measurements with units" do
    get portal_fitting_record_path(@fitting_record)
    assert_select "[data-testid='measurements']"
    assert_match "720.0", response.body   # saddle_height
    assert_match "mm", response.body      # unit
  end

  test "show displays saddle info" do
    get portal_fitting_record_path(@fitting_record)
    assert_select "[data-testid='saddle-info']"
    assert_match "Fizik", response.body
    assert_match "Arione R3", response.body
  end

  test "show displays cleat info" do
    get portal_fitting_record_path(@fitting_record)
    assert_select "[data-testid='cleat-info']"
  end

  test "show displays notes" do
    get portal_fitting_record_path(@fitting_record)
    assert_match @fitting_record.notes, response.body
  end

  test "show has back link to fitting records" do
    get portal_fitting_record_path(@fitting_record)
    assert_select "a[href='#{portal_fitting_records_path}']"
  end

  test "show cannot access other customer fitting record" do
    other_record = fitting_records(:gravel_fitting) # belongs to customer two's bike
    get portal_fitting_record_path(other_record)
    assert_response :not_found
  end
end
