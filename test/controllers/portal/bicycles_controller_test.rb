require "test_helper"

class Portal::BicyclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @bicycle = bicycles(:road_bike)
    # Login
    post portal_login_path, params: { phone: @customer.phone }
  end

  # --- Authentication ---

  test "index requires authentication" do
    delete portal_logout_path
    get portal_bicycles_path
    assert_redirected_to portal_login_path
  end

  test "show requires authentication" do
    delete portal_logout_path
    get portal_bicycle_path(@bicycle)
    assert_redirected_to portal_login_path
  end

  # --- Index ---

  test "index renders successfully" do
    get portal_bicycles_path
    assert_response :ok
  end

  test "index shows customer bicycles" do
    get portal_bicycles_path
    assert_match @bicycle.brand, response.body
    assert_match @bicycle.model_label, response.body
  end

  test "index has bicycle cards" do
    get portal_bicycles_path
    assert_select "[data-testid='bicycle-card']", minimum: 1
  end

  test "index does not show other customers bicycles" do
    get portal_bicycles_path
    other_bike = bicycles(:gravel_bike)
    # gravel_bike belongs to customer two
    assert_no_match other_bike.frame_number, response.body
  end

  test "index page title contains 내 자전거" do
    get portal_bicycles_path
    assert_select "title", text: /내 자전거/
  end

  test "index shows bike_type badge" do
    get portal_bicycles_path
    assert_match "ROAD", response.body
  end

  # --- Show ---

  test "show renders successfully" do
    get portal_bicycle_path(@bicycle)
    assert_response :ok
  end

  test "show displays bicycle details" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.brand, response.body
    assert_match @bicycle.model_label, response.body
  end

  test "show displays year" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.year.to_s, response.body
  end

  test "show displays color" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.color, response.body
  end

  test "show displays frame number" do
    get portal_bicycle_path(@bicycle)
    assert_match @bicycle.frame_number, response.body
  end

  test "show has back link to bicycle list" do
    get portal_bicycle_path(@bicycle)
    assert_select "a[href='#{portal_bicycles_path}']"
  end

  test "show cannot access other customer bicycle" do
    other_bike = bicycles(:gravel_bike)
    get portal_bicycle_path(other_bike)
    assert_response :not_found
  end

  # --- Layout ---

  test "uses portal layout" do
    get portal_bicycles_path
    assert_select "nav[aria-label='Portal navigation']"
  end

  test "has bottom navigation with correct items" do
    get portal_bicycles_path
    assert_select "nav[aria-label='Portal navigation']" do
      assert_select "a", text: /내 자전거/
      assert_select "a", text: /정비이력/
      assert_select "a", text: /피팅/
      assert_select "[data-testid='nav-profile']", text: /내 정보/
    end
  end

  test "header shows customer name" do
    get portal_bicycles_path
    assert_match @customer.name, response.body
  end

  test "header shows Today.bike logo" do
    get portal_bicycles_path
    assert_match "Today.bike", response.body
  end
end
