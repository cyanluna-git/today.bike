require "test_helper"

class Admin::BicyclesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @bicycle = bicycles(:road_bike)
    @customer = customers(:one)
    @service_inquiry = ServiceInquiry.create!(
      name: "문의 고객",
      phone: "010-2222-4444",
      message: "자전거 접수 문의",
      customer: @customer,
      conversion_status: "customer_linked"
    )
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_bicycles_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_bicycle_path(@bicycle)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_bicycle_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_bicycles_path, params: { bicycle: { brand: "Test", model_label: "Bike", customer_id: @customer.id } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_bicycle_path(@bicycle)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_bicycle_path(@bicycle), params: { bicycle: { brand: "Updated" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_bicycle_path(@bicycle)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_response :ok
  end

  test "index displays bicycles in a table" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "table"
    assert_select "td", text: /Specialized/
  end

  test "index page title contains Bicycles" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "title", text: /Bicycles/
  end

  test "index has New Bicycle link" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "a[href='#{new_admin_bicycle_path}']", text: /New Bicycle/
  end

  # --- Filters ---

  test "index has filter form with bike_type and status selects" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "select[name='bike_type']"
    assert_select "select[name='status']"
  end

  test "filter by bike_type returns matching bicycles" do
    sign_in @admin_user
    get admin_bicycles_path, params: { bike_type: "road" }
    assert_response :ok
    assert_select "td", text: /Specialized/
    assert_select "td", text: /Trek/, count: 0
  end

  test "filter by status returns matching bicycles" do
    sign_in @admin_user
    get admin_bicycles_path, params: { status: "sold" }
    assert_response :ok
    assert_select "td", text: /Pinarello/
    assert_select "td", text: /Specialized/, count: 0
  end

  test "filter by both bike_type and status" do
    sign_in @admin_user
    get admin_bicycles_path, params: { bike_type: "road", status: "active" }
    assert_response :ok
    assert_select "td", text: /Specialized/
    assert_select "td", text: /Pinarello/, count: 0
  end

  test "filter with no match shows empty state" do
    sign_in @admin_user
    get admin_bicycles_path, params: { bike_type: "hybrid" }
    assert_response :ok
    assert_select "td[colspan='5']"
  end

  # --- Turbo Frame ---

  test "index wraps table in turbo frame" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "turbo-frame#bicycles_table"
  end

  test "filter form targets bicycles_table turbo frame" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "form[data-turbo-frame='bicycles_table']"
  end

  # --- Pagination ---

  test "index paginates bicycles" do
    sign_in @admin_user
    22.times do |i|
      Bicycle.create!(brand: "Brand#{i}", model_label: "Model#{i}", customer: @customer)
    end
    get admin_bicycles_path
    assert_response :ok
    assert_select "nav[aria-label='Pagination']"
  end

  test "index page 2 returns second page of bicycles" do
    sign_in @admin_user
    22.times do |i|
      Bicycle.create!(brand: "Brand#{i}", model_label: "Model#{i}", customer: @customer)
    end
    get admin_bicycles_path, params: { page: 2 }
    assert_response :ok
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_response :ok
  end

  test "show displays bicycle details" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_match @bicycle.brand, response.body
    assert_match @bicycle.model_label, response.body
  end

  test "show has edit and delete actions" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_select "a[href='#{edit_admin_bicycle_path(@bicycle)}']", text: "Edit"
    assert_select "form[action='#{admin_bicycle_path(@bicycle)}']"
  end

  test "show has back to bicycles link" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_select "a[href='#{admin_bicycles_path}']", text: /Back to Bicycles/
  end

  test "show displays customer link" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_select "a[href='#{admin_customer_path(@bicycle.customer)}']", text: @bicycle.customer.name
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_bicycle_path
    assert_response :ok
  end

  test "new renders a form" do
    sign_in @admin_user
    get new_admin_bicycle_path
    assert_select "form"
    assert_select "input[name='bicycle[brand]']"
    assert_select "input[name='bicycle[model_label]']"
    assert_select "select[name='bicycle[customer_id]']"
  end

  test "new pre-fills customer_id when provided" do
    sign_in @admin_user
    get new_admin_bicycle_path(customer_id: @customer.id)
    assert_response :ok
    assert_select "select[name='bicycle[customer_id]'] option[selected][value='#{@customer.id}']"
  end

  test "new with inquiry pre-fills customer and hidden inquiry id" do
    sign_in @admin_user

    get new_admin_bicycle_path, params: { service_inquiry_id: @service_inquiry.id }

    assert_response :ok
    assert_select "select[name='bicycle[customer_id]'] option[selected][value='#{@customer.id}']"
    assert_select "input[name='service_inquiry_id'][value='#{@service_inquiry.id}']", count: 1
    assert_match "문의에서 자전거 생성", response.body
  end

  # --- Create ---

  test "create with valid params creates bicycle and redirects" do
    sign_in @admin_user

    assert_difference "Bicycle.count", 1 do
      post admin_bicycles_path, params: {
        bicycle: {
          brand: "Canyon",
          model_label: "Aeroad CFR",
          year: 2024,
          frame_number: "CYN2024AER000001",
          bike_type: "road",
          color: "블랙",
          status: "active",
          customer_id: @customer.id
        }
      }
    end

    bicycle = Bicycle.last
    assert_redirected_to admin_bicycle_path(bicycle)
    follow_redirect!
    assert_match "Bicycle was successfully created", response.body
  end

  test "create from inquiry links bicycle and returns to inquiry" do
    sign_in @admin_user

    assert_difference "Bicycle.count", 1 do
      post admin_bicycles_path, params: {
        service_inquiry_id: @service_inquiry.id,
        bicycle: {
          customer_id: @customer.id,
          brand: "Cervelo",
          model_label: "Soloist",
          bike_type: "road",
          status: "active"
        }
      }
    end

    assert_redirected_to admin_service_inquiry_path(@service_inquiry)
    @service_inquiry.reload
    assert_equal "bicycle_linked", @service_inquiry.conversion_status
    assert_equal "Cervelo", @service_inquiry.bicycle.brand
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "Bicycle.count" do
      post admin_bicycles_path, params: {
        bicycle: { brand: "", model_label: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_bicycle_path(@bicycle)
    assert_response :ok
  end

  test "edit renders a form with existing values" do
    sign_in @admin_user
    get edit_admin_bicycle_path(@bicycle)
    assert_select "input[name='bicycle[brand]'][value='#{@bicycle.brand}']"
  end

  # --- Update ---

  test "update with valid params updates bicycle and redirects" do
    sign_in @admin_user

    patch admin_bicycle_path(@bicycle), params: {
      bicycle: { brand: "Updated Brand" }
    }

    assert_redirected_to admin_bicycle_path(@bicycle)
    follow_redirect!
    assert_match "Bicycle was successfully updated", response.body
    assert_equal "Updated Brand", @bicycle.reload.brand
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_bicycle_path(@bicycle), params: {
      bicycle: { brand: "" }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes bicycle and redirects to index" do
    sign_in @admin_user

    assert_difference "Bicycle.count", -1 do
      delete admin_bicycle_path(@bicycle)
    end

    assert_redirected_to admin_bicycles_path
    follow_redirect!
    assert_match "Bicycle was successfully deleted", response.body
  end

  # --- Customer show page displays bicycles ---

  test "customer show page displays bicycles list" do
    sign_in @admin_user
    get admin_customer_path(@customer)
    assert_response :ok
    assert_select "h2", text: /Bicycles/
    assert_match "Specialized", response.body
    assert_match "Tarmac SL7", response.body
  end

  test "customer show page has add bicycle link with customer_id" do
    sign_in @admin_user
    get admin_customer_path(@customer)
    assert_select "a[href='#{new_admin_bicycle_path(customer_id: @customer.id)}']", text: /Add Bicycle/
  end

  # --- Photo Upload ---

  test "create with photos attaches photos to bicycle" do
    sign_in @admin_user

    photo = fixture_file_upload("test_photo.png", "image/png")

    assert_difference "Bicycle.count", 1 do
      post admin_bicycles_path, params: {
        bicycle: {
          brand: "Canyon",
          model_label: "Aeroad CFR",
          bike_type: "road",
          customer_id: @customer.id,
          photos: [ photo ]
        }
      }
    end

    bicycle = Bicycle.last
    assert_equal 1, bicycle.photos.count
    assert_redirected_to admin_bicycle_path(bicycle)
  end

  test "update with photos attaches additional photos" do
    sign_in @admin_user

    photo = fixture_file_upload("test_photo.png", "image/png")

    patch admin_bicycle_path(@bicycle), params: {
      bicycle: { photos: [ photo ] }
    }

    assert_redirected_to admin_bicycle_path(@bicycle)
    assert_equal 1, @bicycle.reload.photos.count
  end

  test "update with multiple photos attaches all" do
    sign_in @admin_user

    photo1 = fixture_file_upload("test_photo.png", "image/png")
    photo2 = fixture_file_upload("test_photo2.png", "image/png")

    patch admin_bicycle_path(@bicycle), params: {
      bicycle: { photos: [ photo1, photo2 ] }
    }

    assert_redirected_to admin_bicycle_path(@bicycle)
    assert_equal 2, @bicycle.reload.photos.count
  end

  test "show displays photo gallery when photos attached" do
    sign_in @admin_user

    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.png",
      content_type: "image/png"
    )

    get admin_bicycle_path(@bicycle)
    assert_response :ok
    assert_select "h2", text: "Photos"
    assert_select "#photo_gallery"
  end

  test "show does not display photo gallery when no photos" do
    sign_in @admin_user

    get admin_bicycle_path(@bicycle)
    assert_response :ok
    assert_select "#photo_gallery", count: 0
  end

  test "form has file input for photos" do
    sign_in @admin_user
    get new_admin_bicycle_path
    assert_select "input[type='file'][name='bicycle[photos][]']"
  end

  # --- Photo Deletion ---

  test "purge_photo requires authentication" do
    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.png",
      content_type: "image/png"
    )
    photo_id = @bicycle.photos.first.id

    delete purge_photo_admin_bicycle_path(@bicycle, photo_id: photo_id)
    assert_redirected_to new_admin_user_session_path
  end

  test "purge_photo deletes individual photo and redirects" do
    sign_in @admin_user

    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.png",
      content_type: "image/png"
    )
    photo_id = @bicycle.photos.first.id

    assert_difference -> { @bicycle.photos.count }, -1 do
      delete purge_photo_admin_bicycle_path(@bicycle, photo_id: photo_id)
    end

    assert_redirected_to admin_bicycle_path(@bicycle)
  end

  test "purge_photo responds with turbo_stream" do
    sign_in @admin_user

    @bicycle.photos.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test_photo.png")),
      filename: "bike.png",
      content_type: "image/png"
    )
    photo_id = @bicycle.photos.first.id

    delete purge_photo_admin_bicycle_path(@bicycle, photo_id: photo_id),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
    assert_includes response.body, "turbo-stream"
    assert_includes response.body, "photo_#{photo_id}"
  end

  test "purge_photo with invalid photo_id returns not found" do
    sign_in @admin_user

    delete purge_photo_admin_bicycle_path(@bicycle, photo_id: 999999)
    assert_response :not_found
  end

  # --- Sidebar ---

  test "sidebar has bicycles link" do
    sign_in @admin_user
    get admin_bicycles_path
    assert_select "a[href='#{admin_bicycles_path}']", text: /자전거관리/
  end
end
