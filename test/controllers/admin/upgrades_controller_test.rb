require "test_helper"

class Admin::UpgradesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @service_order = service_orders(:delivered_order)
    @upgrade = upgrades(:wheelset_upgrade)
  end

  # --- Authentication tests ---

  test "create requires authentication" do
    post admin_service_order_upgrades_path(@service_order)
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_service_order_upgrade_path(@service_order, @upgrade)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_service_order_upgrade_path(@service_order, @upgrade)
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_service_order_upgrade_path(@service_order, @upgrade)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Create action ---

  test "create with valid params creates upgrade" do
    sign_in @admin_user

    assert_difference "Upgrade.count", 1 do
      post admin_service_order_upgrades_path(@service_order),
           params: { upgrade: {
             component: "handlebar",
             before_brand: "Bontrager", before_model: "XXX",
             after_brand: "Zipp", after_model: "SL-70 Ergo",
             upgrade_purpose: "aero",
             cost: 350000
           } }
    end

    u = Upgrade.last
    assert_equal "handlebar", u.component
    assert_equal "Bontrager", u.before_brand
    assert_equal "XXX", u.before_model
    assert_equal "Zipp", u.after_brand
    assert_equal "SL-70 Ergo", u.after_model
    assert_equal "aero", u.upgrade_purpose
    assert_equal 350000, u.cost
    assert_equal @service_order.id, u.service_order_id
  end

  test "create responds with turbo_stream" do
    sign_in @admin_user

    post admin_service_order_upgrades_path(@service_order),
         params: { upgrade: { component: "saddle", after_brand: "Fizik", after_model: "Argo", upgrade_purpose: "comfort" } },
         as: :turbo_stream

    assert_response :success
  end

  test "create with invalid params does not create upgrade" do
    sign_in @admin_user

    assert_no_difference "Upgrade.count" do
      post admin_service_order_upgrades_path(@service_order),
           params: { upgrade: { component: "", after_brand: "", after_model: "" } },
           as: :turbo_stream
    end

    assert_response :success
  end

  test "create with minimal params (component + after_brand + after_model + upgrade_purpose)" do
    sign_in @admin_user

    assert_difference "Upgrade.count", 1 do
      post admin_service_order_upgrades_path(@service_order),
           params: { upgrade: { component: "stem", after_brand: "Zipp", after_model: "SL Sprint", upgrade_purpose: "aero" } }
    end

    u = Upgrade.last
    assert_equal "stem", u.component
    assert_equal "Zipp", u.after_brand
    assert_equal "SL Sprint", u.after_model
    assert_equal "aero", u.upgrade_purpose
    assert_nil u.before_brand
    assert_nil u.before_model
    assert_nil u.cost
  end

  # --- Edit action ---

  test "edit responds with turbo_stream" do
    sign_in @admin_user

    get edit_admin_service_order_upgrade_path(@service_order, @upgrade),
        as: :turbo_stream

    assert_response :success
  end

  # --- Update action ---

  test "update with valid params updates upgrade" do
    sign_in @admin_user

    patch admin_service_order_upgrade_path(@service_order, @upgrade),
          params: { upgrade: { after_brand: "ENVE", after_model: "SES 5.6", cost: 2500000 } }

    @upgrade.reload
    assert_equal "ENVE", @upgrade.after_brand
    assert_equal "SES 5.6", @upgrade.after_model
    assert_equal 2500000, @upgrade.cost
  end

  test "update responds with turbo_stream" do
    sign_in @admin_user

    patch admin_service_order_upgrade_path(@service_order, @upgrade),
          params: { upgrade: { cost: 1900000 } },
          as: :turbo_stream

    assert_response :success
  end

  test "update with invalid params does not update upgrade" do
    sign_in @admin_user
    original_brand = @upgrade.after_brand

    patch admin_service_order_upgrade_path(@service_order, @upgrade),
          params: { upgrade: { after_brand: "" } },
          as: :turbo_stream

    @upgrade.reload
    assert_equal original_brand, @upgrade.after_brand
  end

  # --- Destroy action ---

  test "destroy removes upgrade" do
    sign_in @admin_user

    assert_difference "Upgrade.count", -1 do
      delete admin_service_order_upgrade_path(@service_order, @upgrade)
    end
  end

  test "destroy responds with turbo_stream" do
    sign_in @admin_user

    delete admin_service_order_upgrade_path(@service_order, @upgrade),
           as: :turbo_stream

    assert_response :success
  end

  test "destroy only deletes upgrades belonging to the service_order" do
    sign_in @admin_user
    other_upgrade = upgrades(:saddle_upgrade) # belongs to repair_order, not delivered_order

    assert_no_difference "Upgrade.count" do
      delete admin_service_order_upgrade_path(@service_order, other_upgrade)
    end

    assert_response :not_found
  end
end
