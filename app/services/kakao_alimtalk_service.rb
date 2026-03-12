class KakaoAlimtalkService
  attr_reader :customer, :template_code, :variables

  def initialize(customer:, template_code:, variables: {})
    @customer = customer
    @template_code = template_code
    @variables = variables
  end

  def send!
    unless customer.phone.present?
      return { success: false, error: "Customer phone number is missing" }
    end

    message = NotificationTemplate.render(template_code, variables)

    if kakao_api_configured?
      # In production with env vars configured, this would call the Kakao Alimtalk API.
      # Example: KakaoApi.send_alimtalk(phone: customer.phone, template: template_code, message: message)
      send_via_kakao_api(message)
    else
      # Stub mode: log the message but don't actually send
      Rails.logger.info("[KakaoAlimtalk] STUB - Would send to #{customer.phone}: #{message}")
      { success: true, message: message, stub: true }
    end
  end

  private

  def kakao_api_configured?
    ENV["KAKAO_ALIMTALK_API_KEY"].present? && ENV["KAKAO_ALIMTALK_SENDER_KEY"].present?
  end

  def send_via_kakao_api(message)
    # Placeholder for actual Kakao API integration.
    # When API keys are available, implement the HTTP call here.
    Rails.logger.info("[KakaoAlimtalk] API call to #{customer.phone}: #{message}")
    { success: true, message: message }
  rescue => e
    Rails.logger.error("[KakaoAlimtalk] Failed to send to #{customer.phone}: #{e.message}")
    { success: false, error: e.message }
  end
end
