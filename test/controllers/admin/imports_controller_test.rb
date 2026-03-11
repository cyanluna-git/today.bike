require "test_helper"

class Admin::ImportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
  end

  # --- Authentication ---

  test "new requires authentication" do
    get new_admin_import_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_imports_path, params: { import_type: "customers" }
    assert_redirected_to new_admin_user_session_path
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_import_path
    assert_response :ok
  end

  test "new has file upload form" do
    sign_in @admin_user
    get new_admin_import_path
    assert_select "form"
    assert_select "input[type='file']"
    assert_select "select[name='import_type']"
  end

  test "new page title contains import" do
    sign_in @admin_user
    get new_admin_import_path
    assert_select "title", text: /가져오기/
  end

  # --- Create (Customers) ---

  test "create with valid customer CSV creates customers" do
    sign_in @admin_user

    file = create_csv_upload("name,phone,email,memo\n박지민,010-5555-6666,park@example.com,\n")

    assert_difference "Customer.count", 1 do
      post admin_imports_path, params: { import_type: "customers", file: file }
    end

    assert_response :ok
    assert_match "1", response.body # created count
  end

  test "create without file shows error" do
    sign_in @admin_user

    post admin_imports_path, params: { import_type: "customers" }

    assert_response :unprocessable_entity
    assert_match "파일을 선택해주세요", response.body
  end

  test "create with customer CSV shows results page" do
    sign_in @admin_user

    file = create_csv_upload("name,phone,email,memo\n박지민,010-5555-6666,,\n")

    post admin_imports_path, params: { import_type: "customers", file: file }

    assert_response :ok
    assert_select "h1", text: /결과/
  end

  # --- Create (Bicycles) ---

  test "create with valid bicycle CSV creates bicycles" do
    sign_in @admin_user
    customer = customers(:one)

    file = create_csv_upload("customer_phone,brand,model_label,year,bike_type,frame_number,color\n#{customer.phone},Giant,TCR,2024,road,GNTTEST123,블루\n")

    assert_difference "Bicycle.count", 1 do
      post admin_imports_path, params: { import_type: "bicycles", file: file }
    end

    assert_response :ok
  end

  # --- Sidebar link ---

  test "sidebar contains import link" do
    sign_in @admin_user
    get new_admin_import_path
    assert_select "a[href='#{new_admin_import_path}']", text: /데이터 가져오기/
  end

  private

  def create_csv_upload(content)
    tempfile = Tempfile.new(["import", ".csv"])
    tempfile.binmode
    tempfile.write(content)
    tempfile.rewind
    Rack::Test::UploadedFile.new(tempfile.path, "text/csv", false, original_filename: "import.csv")
  end
end
