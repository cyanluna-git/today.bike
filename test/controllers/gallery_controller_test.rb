require "test_helper"

class GalleryControllerTest < ActionDispatch::IntegrationTest
  # --- Index ---

  test "index renders successfully" do
    get gallery_path
    assert_response :ok
  end

  test "index page title contains Gallery" do
    get gallery_path
    assert_select "title", text: /Gallery/
  end

  test "index shows empty state when no showcase orders" do
    get gallery_path
    assert_response :ok
    assert_match "No showcase entries yet", response.body
  end

  test "index shows heading" do
    get gallery_path
    assert_select "h1", text: /Before & After Gallery/
  end
end
