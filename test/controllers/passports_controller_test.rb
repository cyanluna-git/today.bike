require "test_helper"

class PassportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bicycle = bicycles(:road_bike)
    @bicycle.update_columns(passport_token: "test-passport-token-abc123")
  end

  # --- Public access (no auth required) ---

  test "show renders successfully with valid token" do
    get passport_path("test-passport-token-abc123")
    assert_response :ok
  end

  test "show displays bicycle info" do
    get passport_path("test-passport-token-abc123")
    assert_match @bicycle.brand, response.body
    assert_match @bicycle.model_label, response.body
  end

  test "show displays bike type" do
    get passport_path("test-passport-token-abc123")
    assert_match @bicycle.bike_type.titleize, response.body
  end

  test "show displays service history" do
    get passport_path("test-passport-token-abc123")
    assert_match "Service History", response.body
  end

  test "show displays specs when available" do
    get passport_path("test-passport-token-abc123")
    assert_match "Component Specs", response.body
  end

  test "show displays fitting records when available" do
    get passport_path("test-passport-token-abc123")
    assert_match "Latest Fitting Record", response.body
  end

  test "show returns 404 for invalid token" do
    get passport_path("nonexistent-token-xyz")
    assert_response :not_found
  end

  test "show uses passport layout" do
    get passport_path("test-passport-token-abc123")
    assert_match "Bicycle Passport", response.body
  end

  test "show does not require authentication" do
    # No sign_in or session setup needed
    get passport_path("test-passport-token-abc123")
    assert_response :ok
  end
end
