require "test_helper"

class Admin::ServiceInquiriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @pending_inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "정비 문의드립니다.",
      service_type: "repair",
      source_page: "service"
    )
    @responded_inquiry = ServiceInquiry.create!(
      name: "김자전",
      phone: "010-5678-1234",
      message: "상품 문의드립니다.",
      product: products(:chain),
      source_page: "product",
      status: "responded"
    )
  end

  test "index requires authentication" do
    get admin_service_inquiries_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_service_inquiry_path(@pending_inquiry)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_service_inquiry_path(@pending_inquiry), params: {
      service_inquiry: { status: "in_review" }
    }

    assert_redirected_to new_admin_user_session_path
  end

  test "link_customer requires authentication" do
    patch link_customer_admin_service_inquiry_path(@pending_inquiry), params: {
      customer_id: customers(:one).id
    }

    assert_redirected_to new_admin_user_session_path
  end

  test "link_bicycle requires authentication" do
    patch link_bicycle_admin_service_inquiry_path(@pending_inquiry), params: {
      bicycle_id: bicycles(:road_bike).id
    }

    assert_redirected_to new_admin_user_session_path
  end

  test "unlink_linkage requires authentication" do
    patch unlink_linkage_admin_service_inquiry_path(@pending_inquiry), params: {
      target: "customer"
    }

    assert_redirected_to new_admin_user_session_path
  end

  test "index renders and shows inquiries" do
    sign_in @admin_user

    get admin_service_inquiries_path

    assert_response :ok
    assert_match @pending_inquiry.name, response.body
    assert_match @responded_inquiry.name, response.body
  end

  test "index filters by status" do
    sign_in @admin_user

    get admin_service_inquiries_path, params: { status: "pending" }

    assert_response :ok
    assert_match @pending_inquiry.name, response.body
    assert_no_match @responded_inquiry.name, response.body
  end

  test "show renders inquiry detail" do
    sign_in @admin_user

    get admin_service_inquiry_path(@pending_inquiry)

    assert_response :ok
    assert_match "정비 문의드립니다.", response.body
    assert_match "수리", response.body
    assert_match "미연결", response.body
    assert_match "문의 전환 허브", response.body
    assert_match "문의 접수", response.body
    assert_match "고객 연결 필요", response.body
    assert_match customers(:one).name, response.body
    assert_select "select[name='service_inquiry[conversion_status]'] option", count: 1
    assert_select "select[name='service_inquiry[conversion_status]'] option[value='unlinked']"
    assert_select "select[name='service_inquiry[conversion_status]'] option[value='closed']", count: 0
  end

  test "show renders linked entities when present" do
    sign_in @admin_user

    linked_inquiry = ServiceInquiry.create!(
      name: "연결 문의",
      phone: "010-1234-5678",
      message: "오버홀 접수",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    get admin_service_inquiry_path(linked_inquiry)

    assert_response :ok
    assert_match "서비스오더 연결", response.body
    assert_match "연결된 서비스오더", response.body
    assert_select "select[name='service_inquiry[conversion_status]'] option[value='service_order_linked']"
    assert_select "select[name='service_inquiry[conversion_status]'] option[value='closed']"
    assert_select "a[href='#{admin_customer_path(customers(:one))}']", text: customers(:one).name
    assert_select "a[href='#{admin_bicycle_path(bicycles(:road_bike))}']"
    assert_select "a[href='#{admin_service_order_path(service_orders(:overhaul_order))}']", text: service_orders(:overhaul_order).order_number
  end

  test "show renders closed inquiry as closed badge outside the step flow" do
    sign_in @admin_user
    @pending_inquiry.update!(customer: customers(:one), conversion_status: "closed")

    get admin_service_inquiry_path(@pending_inquiry)

    assert_response :ok
    assert_match "운영상 종료", response.body
    assert_match "이 문의는 운영상 종료 처리되었습니다.", response.body
    assert_select "select[name='service_inquiry[conversion_status]'] option[value='customer_linked']"
    assert_select "select[name='service_inquiry[conversion_status]'] option[value='closed']"
  end

  test "update changes status and notes" do
    sign_in @admin_user

    freeze_time do
      patch admin_service_inquiry_path(@pending_inquiry), params: {
        service_inquiry: {
          status: "responded",
          admin_notes: "전화로 일정 안내 완료"
        }
      }

      assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
      @pending_inquiry.reload
      assert_equal "responded", @pending_inquiry.status
      assert_equal "전화로 일정 안내 완료", @pending_inquiry.admin_notes
      assert_equal Time.current, @pending_inquiry.responded_at
    end
  end

  test "update can close inquiry conversion stage" do
    sign_in @admin_user
    @pending_inquiry.update!(customer: customers(:one), conversion_status: "customer_linked")

    patch admin_service_inquiry_path(@pending_inquiry), params: {
      service_inquiry: {
        status: "responded",
        conversion_status: "closed",
        admin_notes: "처리 종료"
      }
    }

    assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
    @pending_inquiry.reload
    assert_equal "closed", @pending_inquiry.conversion_status
  end

  test "link_customer connects existing customer to inquiry" do
    sign_in @admin_user

    patch link_customer_admin_service_inquiry_path(@pending_inquiry), params: {
      customer_id: customers(:one).id
    }

    assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
    @pending_inquiry.reload
    assert_equal customers(:one), @pending_inquiry.customer
    assert_equal "customer_linked", @pending_inquiry.conversion_status
  end

  test "link_bicycle connects existing bicycle to inquiry" do
    sign_in @admin_user
    @pending_inquiry.update!(customer: customers(:one), conversion_status: "customer_linked")

    patch link_bicycle_admin_service_inquiry_path(@pending_inquiry), params: {
      bicycle_id: bicycles(:road_bike).id
    }

    assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
    @pending_inquiry.reload
    assert_equal bicycles(:road_bike), @pending_inquiry.bicycle
    assert_equal "bicycle_linked", @pending_inquiry.conversion_status
  end

  test "unlink_linkage removes service order only" do
    sign_in @admin_user
    @pending_inquiry.update!(
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    patch unlink_linkage_admin_service_inquiry_path(@pending_inquiry), params: {
      target: "service_order"
    }

    assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
    @pending_inquiry.reload
    assert_nil @pending_inquiry.service_order
    assert_equal "bicycle_linked", @pending_inquiry.conversion_status
  end

  test "unlink_linkage removes bicycle and cascades service order" do
    sign_in @admin_user
    @pending_inquiry.update!(
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    patch unlink_linkage_admin_service_inquiry_path(@pending_inquiry), params: {
      target: "bicycle"
    }

    assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
    @pending_inquiry.reload
    assert_nil @pending_inquiry.bicycle
    assert_nil @pending_inquiry.service_order
    assert_equal "customer_linked", @pending_inquiry.conversion_status
  end

  test "unlink_linkage removes customer and clears all links" do
    sign_in @admin_user
    @pending_inquiry.update!(
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    patch unlink_linkage_admin_service_inquiry_path(@pending_inquiry), params: {
      target: "customer"
    }

    assert_redirected_to admin_service_inquiry_path(@pending_inquiry)
    @pending_inquiry.reload
    assert_nil @pending_inquiry.customer
    assert_nil @pending_inquiry.bicycle
    assert_nil @pending_inquiry.service_order
    assert_equal "unlinked", @pending_inquiry.conversion_status
  end
end
