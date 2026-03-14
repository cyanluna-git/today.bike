require "test_helper"

class PortalBicycleLifecycleReminderTest < ActiveSupport::TestCase
  setup do
    @road_bike = bicycles(:road_bike)
  end

  test "returns in progress reminder when active service order exists" do
    reminder = PortalBicycleLifecycleReminder.new(@road_bike, today: Date.new(2026, 3, 14)).call

    assert_equal :info, reminder[:tone]
    assert_equal "진행 중", reminder[:badge]
    assert_equal "현재 정비가 진행 중입니다.", reminder[:title]
  end

  test "returns first record reminder for bicycle without history" do
    bicycle = Bicycle.create!(
      customer: customers(:one),
      brand: "Cervelo",
      model_label: "Soloist",
      bike_type: "road",
      status: "active"
    )

    reminder = PortalBicycleLifecycleReminder.new(bicycle, today: Date.new(2026, 3, 14)).call

    assert_equal :calm, reminder[:tone]
    assert_equal "첫 관리 기록을 남겨두면 좋아요.", reminder[:title]
  end

  test "returns service due reminder when last service is old" do
    bicycle = Bicycle.create!(
      customer: customers(:one),
      brand: "BMC",
      model_label: "Roadmachine",
      bike_type: "road",
      status: "active"
    )
    ServiceOrder.create!(
      bicycle: bicycle,
      order_number: "TB-2025-0199",
      service_type: "repair",
      status: "completed",
      received_at: Time.zone.parse("2025-08-01 10:00:00"),
      completed_at: Time.zone.parse("2025-08-03 16:00:00")
    )

    reminder = PortalBicycleLifecycleReminder.new(bicycle, today: Date.new(2026, 3, 14)).call

    assert_equal :attention, reminder[:tone]
    assert_equal "점검 권장", reminder[:badge]
  end

  test "returns fitting due reminder when service is recent but fitting record is missing" do
    bicycle = Bicycle.create!(
      customer: customers(:one),
      brand: "Factor",
      model_label: "Ostro",
      bike_type: "road",
      status: "active"
    )
    ServiceOrder.create!(
      bicycle: bicycle,
      order_number: "TB-2026-0101",
      service_type: "repair",
      status: "completed",
      received_at: Time.zone.parse("2026-02-25 10:00:00"),
      completed_at: Time.zone.parse("2026-02-27 15:00:00")
    )

    reminder = PortalBicycleLifecycleReminder.new(bicycle, today: Date.new(2026, 3, 14)).call

    assert_equal :calm, reminder[:tone]
    assert_equal "세팅 확인", reminder[:badge]
  end
end
