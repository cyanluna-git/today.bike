class QrCodeService
  APP_BASE_URL = ENV.fetch("APP_BASE_URL", "https://todaybike.cyanluna.com").freeze

  def self.generate_svg(url, size: 4)
    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: size,
      standalone: true,
      use_path: true
    )
  end

  def self.generate_png(url, size: 10)
    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_png(
      bit_depth: 1,
      border_modules: 2,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: size,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 300
    )
  end

  def self.passport_url(token)
    "#{APP_BASE_URL}/passport/#{token}"
  end
end
