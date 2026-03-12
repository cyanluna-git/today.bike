require "test_helper"

class KakaoAlimtalkServiceTest < ActiveSupport::TestCase
  def setup
    @customer = customers(:one)
  end

  test "send! returns success in stub mode" do
    service = KakaoAlimtalkService.new(
      customer: @customer,
      template_code: :completion,
      variables: { customer_name: @customer.name, bicycle_name: "Test Bike" }
    )

    result = service.send!
    assert result[:success]
    assert result[:stub]
    assert_includes result[:message], @customer.name
  end

  test "send! returns failure when customer has no phone" do
    customer = Customer.new(name: "Test", phone: nil)
    # Skip validation to allow nil phone
    customer.define_singleton_method(:phone) { nil }

    service = KakaoAlimtalkService.new(
      customer: customer,
      template_code: :completion,
      variables: { customer_name: "Test" }
    )

    result = service.send!
    assert_not result[:success]
    assert_equal "Customer phone number is missing", result[:error]
  end

  test "send! logs message in stub mode" do
    service = KakaoAlimtalkService.new(
      customer: @customer,
      template_code: :completion,
      variables: { customer_name: @customer.name, bicycle_name: "Trek Madone" }
    )

    assert_nothing_raised { service.send! }
  end
end
