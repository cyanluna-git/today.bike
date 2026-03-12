require "test_helper"

class QrCodeServiceTest < ActiveSupport::TestCase
  test "generate_svg returns SVG string" do
    svg = QrCodeService.generate_svg("https://today.bike/passport/test-token")
    assert_includes svg, "<svg"
    assert_includes svg, "</svg>"
  end

  test "generate_png returns PNG data" do
    png = QrCodeService.generate_png("https://today.bike/passport/test-token")
    assert png.respond_to?(:to_s)
    png_data = png.to_s
    assert png_data.length > 0
  end

  test "passport_url generates correct URL" do
    url = QrCodeService.passport_url("abc123")
    assert_equal "https://today.bike/passport/abc123", url
  end
end
