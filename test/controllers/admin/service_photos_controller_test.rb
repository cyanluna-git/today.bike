require "test_helper"

class Admin::ServicePhotosControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:overhaul_order)
  end

  # --- Authentication tests ---

  test "create requires authentication" do
    post admin_service_order_service_photos_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    photo = service_photos(:before_photo)
    delete admin_service_order_service_photo_path(@service_order, photo)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Create action ---

  test "create with single file creates service_photo" do
    sign_in @admin_user
    file = fixture_file_upload("test_photo.png", "image/png")

    assert_difference "ServicePhoto.count", 1 do
      post admin_service_order_service_photos_path(@service_order),
           params: { images: [file], photo_type: "before", caption: "Test photo" }
    end

    photo = ServicePhoto.last
    assert_equal "before", photo.photo_type
    assert_equal "Test photo", photo.caption
    assert photo.image.attached?
    assert_equal @service_order.id, photo.service_order_id
  end

  test "create with multiple files creates multiple service_photos" do
    sign_in @admin_user
    file1 = fixture_file_upload("test_photo.png", "image/png")
    file2 = fixture_file_upload("test_photo2.png", "image/png")

    assert_difference "ServicePhoto.count", 2 do
      post admin_service_order_service_photos_path(@service_order),
           params: { images: [file1, file2], photo_type: "during", caption: "Multi upload" }
    end
  end

  test "create sets taken_at to current time" do
    sign_in @admin_user
    file = fixture_file_upload("test_photo.png", "image/png")

    freeze_time do
      post admin_service_order_service_photos_path(@service_order),
           params: { images: [file], photo_type: "diagnosis" }

      photo = ServicePhoto.last
      assert_equal Time.current.to_i, photo.taken_at.to_i
    end
  end

  test "create without files redirects with alert" do
    sign_in @admin_user

    assert_no_difference "ServicePhoto.count" do
      post admin_service_order_service_photos_path(@service_order),
           params: { photo_type: "before" }
    end

    assert_redirected_to admin_service_order_path(@service_order)
    assert_equal "Please select at least one photo.", flash[:alert]
  end

  test "create responds with turbo_stream" do
    sign_in @admin_user
    file = fixture_file_upload("test_photo.png", "image/png")

    post admin_service_order_service_photos_path(@service_order),
         params: { images: [file], photo_type: "after" },
         as: :turbo_stream

    assert_response :success
  end

  test "create defaults photo_type to before" do
    sign_in @admin_user
    file = fixture_file_upload("test_photo.png", "image/png")

    post admin_service_order_service_photos_path(@service_order),
         params: { images: [file] }

    photo = ServicePhoto.last
    assert_equal "before", photo.photo_type
  end

  # --- Destroy action ---

  test "destroy removes service_photo" do
    sign_in @admin_user
    photo = service_photos(:before_photo)

    assert_difference "ServicePhoto.count", -1 do
      delete admin_service_order_service_photo_path(@service_order, photo)
    end

    assert_redirected_to admin_service_order_path(@service_order)
  end

  test "destroy responds with turbo_stream" do
    sign_in @admin_user
    photo = service_photos(:before_photo)

    delete admin_service_order_service_photo_path(@service_order, photo),
           as: :turbo_stream

    assert_response :success
  end

  test "destroy only deletes photos belonging to the service_order" do
    sign_in @admin_user
    other_photo = service_photos(:during_photo) # belongs to repair_order, not overhaul_order

    assert_no_difference "ServicePhoto.count" do
      delete admin_service_order_service_photo_path(@service_order, other_photo)
    end

    assert_response :not_found
  end
end
