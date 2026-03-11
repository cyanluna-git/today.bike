require "test_helper"
require "csv"

class CsvImportServiceTest < ActiveSupport::TestCase
  # --- Customer Import ---

  test "imports customers from valid CSV" do
    csv_content = "name,phone,email,memo\n박지민,010-5555-6666,park@example.com,신규 고객\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 1, result[:created]
    assert_equal 0, result[:skipped]
    assert_empty result[:errors]

    customer = Customer.find_by(phone: "010-5555-6666")
    assert_not_nil customer
    assert_equal "박지민", customer.name
    assert_equal "park@example.com", customer.email
    assert_equal "신규 고객", customer.memo
  end

  test "imports multiple customers" do
    csv_content = <<~CSV
      name,phone,email,memo
      박지민,010-5555-6666,park@example.com,
      최수진,010-7777-8888,choi@example.com,VIP
    CSV
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 2, result[:created]
    assert_equal 0, result[:skipped]
    assert_empty result[:errors]
  end

  test "skips customers with duplicate phone number" do
    existing = customers(:one) # phone: 010-1234-5678
    csv_content = "name,phone,email,memo\n중복,#{existing.phone},dup@example.com,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:skipped]
    assert_empty result[:errors]
  end

  test "reports error for customer with missing required fields" do
    csv_content = "name,phone,email,memo\n,010-5555-6666,,\n박지민,,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 0, result[:created]
    assert_equal 2, result[:errors].size
    assert_match "Row 2", result[:errors][0]
    assert_match "Row 3", result[:errors][1]
  end

  test "reports error for customer with invalid phone format" do
    csv_content = "name,phone,email,memo\n박지민,12345,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:errors].size
    assert_match "Row 2", result[:errors][0]
  end

  test "handles mix of created skipped and errored customers" do
    existing = customers(:one)
    csv_content = <<~CSV
      name,phone,email,memo
      새고객,010-3333-4444,,
      중복,#{existing.phone},,
      ,,,
    CSV
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 1, result[:created]
    assert_equal 1, result[:skipped]
    assert_equal 1, result[:errors].size
  end

  test "handles UTF-8 BOM in customer CSV" do
    csv_content = "\xEF\xBB\xBFname,phone,email,memo\n박지민,010-5555-6666,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 1, result[:created]
    assert_empty result[:errors]
  end

  test "customer import handles blank email and memo gracefully" do
    csv_content = "name,phone,email,memo\n박지민,010-5555-6666,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 1, result[:created]
    customer = Customer.find_by(phone: "010-5555-6666")
    assert_nil customer.email
    assert_nil customer.memo
  end

  # --- Bicycle Import ---

  test "imports bicycles from valid CSV" do
    customer = customers(:one)
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n#{customer.phone},Giant,TCR,2024,road,GNT12345,블루\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 1, result[:created]
    assert_equal 0, result[:skipped]
    assert_empty result[:errors]

    bicycle = Bicycle.find_by(frame_number: "GNT12345")
    assert_not_nil bicycle
    assert_equal customer, bicycle.customer
    assert_equal "Giant", bicycle.brand
    assert_equal "TCR", bicycle.model_label
    assert_equal 2024, bicycle.year
    assert_equal "road", bicycle.bike_type
    assert_equal "블루", bicycle.color
  end

  test "reports error when bicycle customer not found" do
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n010-0000-0000,Giant,TCR,2024,road,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:errors].size
    assert_match "not found", result[:errors][0]
  end

  test "reports error for bicycle with missing required fields" do
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n,,,,,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:errors].size
    assert_match "required", result[:errors][0]
  end

  test "reports error for bicycle with invalid bike_type" do
    customer = customers(:one)
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n#{customer.phone},Giant,TCR,2024,invalid_type,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:errors].size
    assert_match "invalid bike_type", result[:errors][0]
  end

  test "imports bicycle with default bike_type when empty" do
    customer = customers(:one)
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n#{customer.phone},Giant,TCR,2024,,,\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 1, result[:created]
    bicycle = Bicycle.last
    assert_equal "road", bicycle.bike_type
  end

  test "imports bicycle without optional fields" do
    customer = customers(:one)
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n#{customer.phone},Giant,TCR,,,, \n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 1, result[:created]
    bicycle = Bicycle.last
    assert_nil bicycle.year
    assert_nil bicycle.frame_number
    assert_nil bicycle.color
  end

  test "reports error for bicycle with duplicate frame_number" do
    customer = customers(:one)
    existing_bike = bicycles(:road_bike)
    csv_content = "customer_phone,brand,model_label,year,bike_type,frame_number,color\n#{customer.phone},Giant,TCR,2024,road,#{existing_bike.frame_number},\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "bicycles").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:errors].size
  end

  # --- Edge cases ---

  test "returns error for unknown import type" do
    csv_content = "name,phone\nTest,010-1111-2222\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "unknown").call

    assert_equal 0, result[:created]
    assert_equal 1, result[:errors].size
    assert_match "Unknown import type", result[:errors][0]
  end

  test "handles empty CSV file" do
    csv_content = "name,phone,email,memo\n"
    file = create_uploaded_file(csv_content)

    result = CsvImportService.new(file, "customers").call

    assert_equal 0, result[:created]
    assert_equal 0, result[:skipped]
    assert_empty result[:errors]
  end

  private

  def create_uploaded_file(content, filename: "test.csv", content_type: "text/csv")
    tempfile = Tempfile.new(["test", ".csv"])
    tempfile.write(content)
    tempfile.rewind
    ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: filename,
      type: content_type
    )
  end
end
