require "test_helper"

class Admin::FrameChangesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:delivered_order)
    @frame_change = frame_changes(:frame_change_one)
  end

  # --- Authentication tests ---

  test "create requires authentication" do
    post admin_service_order_frame_changes_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_service_order_frame_change_path(@service_order, @frame_change)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_service_order_frame_change_path(@service_order, @frame_change)
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_service_order_frame_change_path(@service_order, @frame_change)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Create action ---

  test "create with valid params creates frame_change" do
    sign_in @admin_user

    assert_difference "FrameChange.count", 1 do
      post admin_service_order_frame_changes_path(@service_order),
           params: { frame_change: {
             old_frame_brand: "Pinarello", old_frame_model: "Dogma F",
             new_frame_brand: "Cervelo", new_frame_model: "R5",
             new_frame_size: "56",
             transferred_parts: %w[wheelset groupset],
             reason: "프레임 변경",
             cost: 4000000
           } }
    end

    fc = FrameChange.last
    assert_equal "Pinarello", fc.old_frame_brand
    assert_equal "Cervelo", fc.new_frame_brand
    assert_equal "R5", fc.new_frame_model
    assert_equal "56", fc.new_frame_size
    assert_includes fc.transferred_parts, "wheelset"
    assert_includes fc.transferred_parts, "groupset"
    assert_equal "프레임 변경", fc.reason
    assert_equal 4000000, fc.cost
    assert_equal @service_order.id, fc.service_order_id
  end

  test "create responds with turbo_stream" do
    sign_in @admin_user

    post admin_service_order_frame_changes_path(@service_order),
         params: { frame_change: { new_frame_brand: "Trek", new_frame_model: "Madone" } },
         as: :turbo_stream

    assert_response :success
  end

  test "create with invalid params does not create frame_change" do
    sign_in @admin_user

    assert_no_difference "FrameChange.count" do
      post admin_service_order_frame_changes_path(@service_order),
           params: { frame_change: { new_frame_brand: "", new_frame_model: "" } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test "create with minimal params (new_frame_brand + new_frame_model)" do
    sign_in @admin_user

    assert_difference "FrameChange.count", 1 do
      post admin_service_order_frame_changes_path(@service_order),
           params: { frame_change: { new_frame_brand: "Giant", new_frame_model: "TCR Advanced" } }
    end

    fc = FrameChange.last
    assert_equal "Giant", fc.new_frame_brand
    assert_equal "TCR Advanced", fc.new_frame_model
    assert_nil fc.old_frame_brand
    assert_nil fc.old_frame_model
    assert_nil fc.new_frame_size
    assert_equal [], fc.transferred_parts
    assert_nil fc.reason
    assert_nil fc.cost
  end

  # --- Edit action ---

  test "edit responds with turbo_stream" do
    sign_in @admin_user

    get edit_admin_service_order_frame_change_path(@service_order, @frame_change),
        as: :turbo_stream

    assert_response :success
  end

  # --- Update action ---

  test "update with valid params updates frame_change" do
    sign_in @admin_user

    patch admin_service_order_frame_change_path(@service_order, @frame_change),
          params: { frame_change: { new_frame_brand: "Trek", new_frame_model: "Madone Gen 8", cost: 6000000 } }

    @frame_change.reload
    assert_equal "Trek", @frame_change.new_frame_brand
    assert_equal "Madone Gen 8", @frame_change.new_frame_model
    assert_equal 6000000, @frame_change.cost
  end

  test "update responds with turbo_stream" do
    sign_in @admin_user

    patch admin_service_order_frame_change_path(@service_order, @frame_change),
          params: { frame_change: { cost: 5500000 } },
          as: :turbo_stream

    assert_response :success
  end

  test "update with invalid params does not update frame_change" do
    sign_in @admin_user
    original_brand = @frame_change.new_frame_brand

    patch admin_service_order_frame_change_path(@service_order, @frame_change),
          params: { frame_change: { new_frame_brand: "" } },
          as: :turbo_stream

    @frame_change.reload
    assert_equal original_brand, @frame_change.new_frame_brand
  end

  # --- Destroy action ---

  test "destroy removes frame_change" do
    sign_in @admin_user

    assert_difference "FrameChange.count", -1 do
      delete admin_service_order_frame_change_path(@service_order, @frame_change)
    end
  end

  test "destroy responds with turbo_stream" do
    sign_in @admin_user

    delete admin_service_order_frame_change_path(@service_order, @frame_change),
           as: :turbo_stream

    assert_response :success
  end
end
