require "test_helper"

class Admin::PartsReplacementsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:completed_order)
    @parts_replacement = parts_replacements(:chain_replacement)
  end

  # --- Authentication tests ---

  test "create requires authentication" do
    post admin_service_order_parts_replacements_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_service_order_parts_replacement_path(@service_order, @parts_replacement)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_service_order_parts_replacement_path(@service_order, @parts_replacement)
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_service_order_parts_replacement_path(@service_order, @parts_replacement)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Create action ---

  test "create with valid params creates parts_replacement" do
    sign_in @admin_user

    assert_difference "PartsReplacement.count", 1 do
      post admin_service_order_parts_replacements_path(@service_order),
           params: { parts_replacement: {
             component: "brakes",
             old_brand: "Shimano", old_model: "BR-R8000",
             new_brand: "Shimano", new_model: "BR-R8100",
             reason: "브레이크 업그레이드",
             cost: 150000
           } }
    end

    pr = PartsReplacement.last
    assert_equal "brakes", pr.component
    assert_equal "Shimano", pr.old_brand
    assert_equal "BR-R8000", pr.old_model
    assert_equal "Shimano", pr.new_brand
    assert_equal "BR-R8100", pr.new_model
    assert_equal "브레이크 업그레이드", pr.reason
    assert_equal 150000, pr.cost
    assert_equal @service_order.id, pr.service_order_id
  end

  test "create responds with turbo_stream" do
    sign_in @admin_user

    post admin_service_order_parts_replacements_path(@service_order),
         params: { parts_replacement: { component: "tire", new_brand: "Continental", new_model: "GP5000" } },
         as: :turbo_stream

    assert_response :success
  end

  test "create with invalid params does not create parts_replacement" do
    sign_in @admin_user

    assert_no_difference "PartsReplacement.count" do
      post admin_service_order_parts_replacements_path(@service_order),
           params: { parts_replacement: { component: "", new_brand: "", new_model: "" } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test "create with minimal params (component + new_brand + new_model)" do
    sign_in @admin_user

    assert_difference "PartsReplacement.count", 1 do
      post admin_service_order_parts_replacements_path(@service_order),
           params: { parts_replacement: { component: "bartape", new_brand: "Lizard Skins", new_model: "DSP 3.2mm" } }
    end

    pr = PartsReplacement.last
    assert_equal "bartape", pr.component
    assert_equal "Lizard Skins", pr.new_brand
    assert_equal "DSP 3.2mm", pr.new_model
    assert_nil pr.old_brand
    assert_nil pr.old_model
    assert_nil pr.reason
    assert_nil pr.cost
  end

  # --- Edit action ---

  test "edit responds with turbo_stream" do
    sign_in @admin_user

    get edit_admin_service_order_parts_replacement_path(@service_order, @parts_replacement),
        as: :turbo_stream

    assert_response :success
  end

  # --- Update action ---

  test "update with valid params updates parts_replacement" do
    sign_in @admin_user

    patch admin_service_order_parts_replacement_path(@service_order, @parts_replacement),
          params: { parts_replacement: { new_brand: "KMC", new_model: "X11-SL", cost: 55000 } }

    @parts_replacement.reload
    assert_equal "KMC", @parts_replacement.new_brand
    assert_equal "X11-SL", @parts_replacement.new_model
    assert_equal 55000, @parts_replacement.cost
  end

  test "update responds with turbo_stream" do
    sign_in @admin_user

    patch admin_service_order_parts_replacement_path(@service_order, @parts_replacement),
          params: { parts_replacement: { cost: 50000 } },
          as: :turbo_stream

    assert_response :success
  end

  test "update with invalid params does not update parts_replacement" do
    sign_in @admin_user
    original_brand = @parts_replacement.new_brand

    patch admin_service_order_parts_replacement_path(@service_order, @parts_replacement),
          params: { parts_replacement: { new_brand: "" } },
          as: :turbo_stream

    @parts_replacement.reload
    assert_equal original_brand, @parts_replacement.new_brand
  end

  # --- Destroy action ---

  test "destroy removes parts_replacement" do
    sign_in @admin_user

    assert_difference "PartsReplacement.count", -1 do
      delete admin_service_order_parts_replacement_path(@service_order, @parts_replacement)
    end
  end

  test "destroy responds with turbo_stream" do
    sign_in @admin_user

    delete admin_service_order_parts_replacement_path(@service_order, @parts_replacement),
           as: :turbo_stream

    assert_response :success
  end

  test "destroy only deletes parts_replacements belonging to the service_order" do
    sign_in @admin_user
    other_pr = parts_replacements(:tire_replacement) # belongs to repair_order, not completed_order

    assert_no_difference "PartsReplacement.count" do
      delete admin_service_order_parts_replacement_path(@service_order, other_pr)
    end

    assert_response :not_found
  end
end
