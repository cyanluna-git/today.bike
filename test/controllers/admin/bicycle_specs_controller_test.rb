require "test_helper"

class Admin::BicycleSpecsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @bicycle = bicycles(:road_bike)
    @spec = bicycle_specs(:frame_spec)
  end

  # --- Authentication tests ---

  test "new requires authentication" do
    get new_admin_bicycle_bicycle_spec_path(@bicycle)
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_bicycle_bicycle_specs_path(@bicycle), params: {
      bicycle_spec: { component: "fork", brand: "Enve", component_model: "AR Disc" }
    }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_bicycle_bicycle_spec_path(@bicycle, @spec)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_bicycle_bicycle_spec_path(@bicycle, @spec), params: {
      bicycle_spec: { brand: "Updated" }
    }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_bicycle_bicycle_spec_path(@bicycle, @spec)
    assert_redirected_to new_admin_user_session_path
  end

  # --- New ---

  test "new responds with turbo_stream" do
    sign_in @admin_user
    get new_admin_bicycle_bicycle_spec_path(@bicycle),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :ok
    assert_includes response.body, "turbo-stream"
  end

  test "new redirects to bicycle show for html format" do
    sign_in @admin_user
    get new_admin_bicycle_bicycle_spec_path(@bicycle)
    assert_redirected_to admin_bicycle_path(@bicycle)
  end

  # --- Create ---

  test "create with valid params creates spec and responds with turbo_stream" do
    sign_in @admin_user

    assert_difference "BicycleSpec.count", 1 do
      post admin_bicycle_bicycle_specs_path(@bicycle),
           params: {
             bicycle_spec: {
               component: "fork",
               brand: "Enve",
               component_model: "AR Disc",
               spec_detail: "Full carbon, tapered"
             }
           },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_includes response.body, "turbo-stream"
    spec = BicycleSpec.last
    assert_equal @bicycle, spec.bicycle
    assert_equal "fork", spec.component
    assert_equal "Enve", spec.brand
    assert_equal "AR Disc", spec.component_model
    assert_equal "Full carbon, tapered", spec.spec_detail
  end

  test "create with valid params via html redirects to bicycle show" do
    sign_in @admin_user

    assert_difference "BicycleSpec.count", 1 do
      post admin_bicycle_bicycle_specs_path(@bicycle), params: {
        bicycle_spec: {
          component: "saddle",
          brand: "Fizik",
          component_model: "Antares R3",
          spec_detail: ""
        }
      }
    end

    assert_redirected_to admin_bicycle_path(@bicycle)
    follow_redirect!
    assert_match "Spec was successfully added", response.body
  end

  test "create with invalid params does not create spec" do
    sign_in @admin_user

    assert_no_difference "BicycleSpec.count" do
      post admin_bicycle_bicycle_specs_path(@bicycle),
           params: {
             bicycle_spec: { component: "", brand: "", component_model: "" }
           },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :unprocessable_entity
  end

  test "create with invalid component value does not create spec" do
    sign_in @admin_user

    assert_no_difference "BicycleSpec.count" do
      post admin_bicycle_bicycle_specs_path(@bicycle),
           params: {
             bicycle_spec: { component: "invalid_component", brand: "Test", component_model: "Test" }
           },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit responds with turbo_stream" do
    sign_in @admin_user
    get edit_admin_bicycle_bicycle_spec_path(@bicycle, @spec),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :ok
    assert_includes response.body, "turbo-stream"
  end

  test "edit redirects to bicycle show for html format" do
    sign_in @admin_user
    get edit_admin_bicycle_bicycle_spec_path(@bicycle, @spec)
    assert_redirected_to admin_bicycle_path(@bicycle)
  end

  # --- Update ---

  test "update with valid params updates spec and responds with turbo_stream" do
    sign_in @admin_user

    patch admin_bicycle_bicycle_spec_path(@bicycle, @spec),
          params: {
            bicycle_spec: { brand: "S-Works", component_model: "Tarmac SL8" }
          },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
    assert_includes response.body, "turbo-stream"
    @spec.reload
    assert_equal "S-Works", @spec.brand
    assert_equal "Tarmac SL8", @spec.component_model
  end

  test "update with valid params via html redirects to bicycle show" do
    sign_in @admin_user

    patch admin_bicycle_bicycle_spec_path(@bicycle, @spec), params: {
      bicycle_spec: { brand: "S-Works" }
    }

    assert_redirected_to admin_bicycle_path(@bicycle)
    follow_redirect!
    assert_match "Spec was successfully updated", response.body
    assert_equal "S-Works", @spec.reload.brand
  end

  test "update with invalid params does not update spec" do
    sign_in @admin_user
    original_brand = @spec.brand

    patch admin_bicycle_bicycle_spec_path(@bicycle, @spec),
          params: {
            bicycle_spec: { brand: "" }
          },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :unprocessable_entity
    assert_equal original_brand, @spec.reload.brand
  end

  # --- Destroy ---

  test "destroy deletes spec and responds with turbo_stream" do
    sign_in @admin_user

    assert_difference "BicycleSpec.count", -1 do
      delete admin_bicycle_bicycle_spec_path(@bicycle, @spec),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :ok
    assert_includes response.body, "turbo-stream"
  end

  test "destroy via html redirects to bicycle show" do
    sign_in @admin_user

    assert_difference "BicycleSpec.count", -1 do
      delete admin_bicycle_bicycle_spec_path(@bicycle, @spec)
    end

    assert_redirected_to admin_bicycle_path(@bicycle)
    follow_redirect!
    assert_match "Spec was successfully deleted", response.body
  end

  # --- Scoping: specs belong to correct bicycle ---

  test "cannot access spec from different bicycle" do
    sign_in @admin_user
    other_bicycle = bicycles(:gravel_bike)

    get edit_admin_bicycle_bicycle_spec_path(other_bicycle, @spec),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :not_found
  end

  # --- Show page displays specs section ---

  test "bicycle show page displays specs section" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_response :ok
    assert_select "#bicycle_specs_section"
    assert_select "h2", text: "Component Specs"
  end

  test "bicycle show page displays existing specs" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_response :ok
    assert_match "Specialized", response.body
    assert_match "Tarmac SL7 Expert", response.body
    assert_match "Roval", response.body
  end

  test "bicycle show page has add spec button" do
    sign_in @admin_user
    get admin_bicycle_path(@bicycle)
    assert_select "a[href='#{new_admin_bicycle_bicycle_spec_path(@bicycle)}']", text: /Add Spec/
  end

  test "bicycle show page displays empty state when no specs" do
    sign_in @admin_user
    bicycle = bicycles(:sold_bike)
    get admin_bicycle_path(bicycle)
    assert_response :ok
    assert_match "No component specs registered yet", response.body
  end
end
