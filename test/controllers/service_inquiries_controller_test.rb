require "test_helper"

class ServiceInquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:chain)
  end

  test "new renders successfully" do
    get new_service_inquiry_path
    assert_response :ok
    assert_match "문의나 접수 요청을 남겨주세요.", response.body
  end

  test "new preserves source context from product page" do
    get new_service_inquiry_path(product_id: @product.id, source_page: "product")

    assert_response :ok
    assert_match @product.name, response.body
    assert_select "input[name='service_inquiry[product_id]'][value='#{@product.id}']", count: 1
  end

  test "new preserves source context from home" do
    get new_service_inquiry_path(source_page: "home")

    assert_response :ok
    assert_match "홈에서 시작한 문의", response.body
    assert_select "input[name='service_inquiry[source_page]'][value='home']", count: 1
  end

  test "create saves inquiry and redirects to confirmation" do
    assert_difference "ServiceInquiry.count", 1 do
      post service_inquiries_path, params: {
        service_inquiry: {
          name: "홍길동",
          phone: "010-1234-5678",
          email: "hong@example.com",
          desired_visit_on: "2026-03-20",
          message: "오버홀 문의드립니다.",
          service_type: "overhaul",
          source_page: "service"
        }
      }
    end

    inquiry = ServiceInquiry.order(:created_at).last
    assert_redirected_to confirmation_service_inquiries_path
    assert_equal "service_request", inquiry.request_category
    assert_equal "overhaul", inquiry.service_type
  end

  test "create infers product inquiry automatically" do
    post service_inquiries_path, params: {
      service_inquiry: {
        name: "홍길동",
        phone: "010-1234-5678",
        message: "이 상품 문의드립니다.",
        product_id: @product.id,
        source_page: "product"
      }
    }

    inquiry = ServiceInquiry.order(:created_at).last
    assert_equal "product_inquiry", inquiry.request_category
    assert_equal @product, inquiry.product
  end

  test "create re-renders form when invalid" do
    assert_no_difference "ServiceInquiry.count" do
      post service_inquiries_path, params: {
        service_inquiry: {
          name: "",
          phone: "010",
          message: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "문의 내용", response.body
  end

  test "confirmation renders successfully" do
    get confirmation_service_inquiries_path
    assert_response :ok
    assert_match "문의가 접수되었습니다.", response.body
  end
end
