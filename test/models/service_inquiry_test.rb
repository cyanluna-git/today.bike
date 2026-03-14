require "test_helper"

class ServiceInquiryTest < ActiveSupport::TestCase
  setup do
    @product = products(:chain)
  end

  test "is valid with required attributes" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "브레이크 점검이 필요합니다."
    )

    assert inquiry.valid?
    assert_equal "general", inquiry.request_category
    assert_equal "unlinked", inquiry.conversion_status
  end

  test "infers product inquiry when product is present" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "체인 재고가 있나요?",
      product: @product
    )

    assert inquiry.valid?
    assert_equal "product_inquiry", inquiry.request_category
  end

  test "infers fitting consultation from service type" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "피팅 상담받고 싶습니다.",
      service_type: "fitting"
    )

    assert inquiry.valid?
    assert_equal "fitting_consultation", inquiry.request_category
  end

  test "infers service request from non fitting service type" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "오버홀 문의드립니다.",
      service_type: "overhaul"
    )

    assert inquiry.valid?
    assert_equal "service_request", inquiry.request_category
  end

  test "requires valid phone format" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "02-123-4567",
      message: "문의합니다."
    )

    assert_not inquiry.valid?
    assert_includes inquiry.errors[:phone], "는 올바른 한국 휴대폰 번호 형식이어야 합니다"
  end

  test "sets responded_at when status changes to responded" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다."
    )

    freeze_time do
      inquiry.update!(status: "responded")
      assert_equal Time.current, inquiry.responded_at
    end
  end

  test "clears responded_at when status moves back from responded" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다.",
      status: "responded",
      responded_at: Time.zone.parse("2026-03-14 09:00:00")
    )

    inquiry.update!(status: "in_review")

    assert_nil inquiry.responded_at
  end

  test "conversion_status_label returns Korean label" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다.",
      conversion_status: "customer_linked",
      customer: customers(:one)
    )

    assert_equal "고객 연결", inquiry.conversion_status_label
  end

  test "available_conversion_statuses only expose reachable states" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다."
    )
    assert_equal [ "unlinked" ], inquiry.available_conversion_statuses

    inquiry.customer = customers(:one)
    inquiry.conversion_status = "customer_linked"
    assert_equal [ "customer_linked", "closed" ], inquiry.available_conversion_statuses

    inquiry.bicycle = bicycles(:road_bike)
    inquiry.conversion_status = "bicycle_linked"
    assert_equal [ "bicycle_linked", "closed" ], inquiry.available_conversion_statuses
  end

  test "customer_candidates match normalized phone" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "01012345678",
      message: "문의합니다."
    )

    assert_equal [ customers(:one) ], inquiry.customer_candidates.to_a
  end

  test "customer_prefill_attributes include inquiry summary memo" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-1234-5678",
      email: "hong@example.com",
      message: "브레이크 점검과 소음 확인 부탁드립니다.",
      service_type: "repair",
      desired_visit_on: Date.new(2026, 3, 20),
      source_page: "service"
    )

    attrs = inquiry.customer_prefill_attributes

    assert_equal "홍길동", attrs[:name]
    assert_equal "010-1234-5678", attrs[:phone]
    assert_equal "hong@example.com", attrs[:email]
    assert_equal true, attrs[:active]
    assert_includes attrs[:memo], "문의 접수에서 생성된 고객"
    assert_includes attrs[:memo], "유입: 수리 페이지"
    assert_includes attrs[:memo], "희망 방문일: 2026-03-20"
  end

  test "link_customer! updates conversion status" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-2222-3333",
      message: "문의합니다."
    )

    inquiry.link_customer!(customers(:two))

    assert_equal customers(:two), inquiry.reload.customer
    assert_equal "customer_linked", inquiry.conversion_status
  end

  test "link_bicycle! updates conversion status" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-2222-3333",
      message: "문의합니다.",
      customer: customers(:one),
      conversion_status: "customer_linked"
    )

    inquiry.link_bicycle!(bicycles(:road_bike))

    assert_equal bicycles(:road_bike), inquiry.reload.bicycle
    assert_equal "bicycle_linked", inquiry.conversion_status
  end

  test "service_order_prefill_attributes include intake summary" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-3333-4444",
      message: "오버홀 접수 문의드립니다.",
      service_type: "overhaul",
      desired_visit_on: Date.new(2026, 3, 21),
      source_page: "service",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      conversion_status: "bicycle_linked"
    )

    attrs = inquiry.service_order_prefill_attributes

    assert_equal bicycles(:road_bike).id, attrs[:bicycle_id]
    assert_equal "overhaul", attrs[:service_type]
    assert_includes attrs[:diagnosis_note], "[문의 접수 전환]"
    assert_includes attrs[:diagnosis_note], "희망 방문일: 2026-03-21"
  end

  test "link_service_order! updates conversion status" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-3333-4444",
      message: "문의합니다.",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      conversion_status: "bicycle_linked"
    )

    inquiry.link_service_order!(service_orders(:overhaul_order))

    assert_equal service_orders(:overhaul_order), inquiry.reload.service_order
    assert_equal "service_order_linked", inquiry.conversion_status
  end

  test "unlink_service_order! rolls back to bicycle_linked" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-3333-4444",
      message: "문의합니다.",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    inquiry.unlink_service_order!

    assert_nil inquiry.reload.service_order
    assert_equal "bicycle_linked", inquiry.conversion_status
  end

  test "unlink_bicycle! also clears service_order" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-3333-4444",
      message: "문의합니다.",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    inquiry.unlink_bicycle!

    inquiry.reload
    assert_nil inquiry.bicycle
    assert_nil inquiry.service_order
    assert_equal "customer_linked", inquiry.conversion_status
  end

  test "unlink_customer! clears all linked entities" do
    inquiry = ServiceInquiry.create!(
      name: "홍길동",
      phone: "010-3333-4444",
      message: "문의합니다.",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:overhaul_order),
      conversion_status: "service_order_linked"
    )

    inquiry.unlink_customer!

    inquiry.reload
    assert_nil inquiry.customer
    assert_nil inquiry.bicycle
    assert_nil inquiry.service_order
    assert_equal "unlinked", inquiry.conversion_status
  end

  test "customer_linked requires linked customer" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다.",
      conversion_status: "customer_linked"
    )

    assert_not inquiry.valid?
    assert_includes inquiry.errors[:conversion_status], "must match the currently linked entities"
  end

  test "bicycle must belong to linked customer" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다.",
      customer: customers(:one),
      bicycle: bicycles(:gravel_bike),
      conversion_status: "bicycle_linked"
    )

    assert_not inquiry.valid?
    assert_includes inquiry.errors[:bicycle], "must belong to the linked customer"
  end

  test "service_order must belong to linked bicycle" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다.",
      customer: customers(:one),
      bicycle: bicycles(:road_bike),
      service_order: service_orders(:repair_order),
      conversion_status: "service_order_linked"
    )

    assert_not inquiry.valid?
    assert_includes inquiry.errors[:service_order], "must belong to the linked bicycle"
  end

  test "closed requires linked customer" do
    inquiry = ServiceInquiry.new(
      name: "홍길동",
      phone: "010-1234-5678",
      message: "문의합니다.",
      conversion_status: "closed"
    )

    assert_not inquiry.valid?
    assert_includes inquiry.errors[:conversion_status], "requires a linked customer before closing"
  end
end
