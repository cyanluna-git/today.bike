require "test_helper"

class ServiceOrderTest < ActiveSupport::TestCase
  def setup
    @bicycle = bicycles(:road_bike)
    @service_order = ServiceOrder.new(
      bicycle: @bicycle,
      service_type: "overhaul",
      expected_completion: Date.new(2026, 3, 20),
      diagnosis_note: "풀 오버홀 필요",
      estimated_cost: 400000
    )
  end

  # --- Valid record ---

  test "valid service order with all fields" do
    assert @service_order.valid?
  end

  test "valid service order with minimal fields (bicycle, service_type)" do
    order = ServiceOrder.new(bicycle: @bicycle, service_type: "repair")
    assert order.valid?
  end

  # --- order_number auto-generation ---

  test "order_number is auto-generated on create" do
    @service_order.save!
    assert_match(/\ATB-\d{4}-\d{4}\z/, @service_order.order_number)
  end

  test "order_number uses current year" do
    @service_order.save!
    current_year = Time.current.year
    assert @service_order.order_number.start_with?("TB-#{current_year}-")
  end

  test "order_number is unique" do
    @service_order.save!
    another = ServiceOrder.new(bicycle: @bicycle, service_type: "repair")
    another.save!
    assert_not_equal @service_order.order_number, another.order_number
  end

  test "order_number increments within the year" do
    @service_order.save!
    another = ServiceOrder.new(bicycle: @bicycle, service_type: "repair")
    another.save!

    first_seq = @service_order.order_number.last(4).to_i
    second_seq = another.order_number.last(4).to_i
    assert_equal first_seq + 1, second_seq
  end

  test "order_number is zero-padded to 4 digits" do
    @service_order.save!
    sequence_part = @service_order.order_number.split("-").last
    assert_equal 4, sequence_part.length
  end

  test "order_number cannot be set manually before create" do
    @service_order.order_number = "CUSTOM-001"
    @service_order.save!
    # before_create callback overwrites any manually set order_number
    assert_match(/\ATB-\d{4}-\d{4}\z/, @service_order.order_number)
  end

  test "order_number uniqueness validation" do
    @service_order.save!
    duplicate = ServiceOrder.new(
      bicycle: @bicycle,
      service_type: "repair",
      order_number: @service_order.order_number
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:order_number], "has already been taken"
  end

  # --- received_at auto-set ---

  test "received_at is auto-set on create" do
    freeze_time do
      @service_order.save!
      assert_equal Time.current, @service_order.received_at
    end
  end

  test "received_at preserves manually set value" do
    custom_time = Time.zone.parse("2026-03-01 10:00:00")
    @service_order.received_at = custom_time
    @service_order.save!
    assert_equal custom_time, @service_order.received_at
  end

  # --- bicycle association ---

  test "invalid without bicycle" do
    @service_order.bicycle = nil
    assert_not @service_order.valid?
    assert_includes @service_order.errors[:bicycle], "must exist"
  end

  test "belongs to bicycle" do
    order = service_orders(:overhaul_order)
    assert_equal bicycles(:road_bike), order.bicycle
  end

  # --- customer through bicycle ---

  test "has one customer through bicycle" do
    order = service_orders(:overhaul_order)
    assert_equal customers(:one), order.customer
  end

  # --- service_type enum ---

  test "service_type overhaul" do
    @service_order.service_type = "overhaul"
    assert @service_order.overhaul?
  end

  test "service_type repair" do
    @service_order.service_type = "repair"
    assert @service_order.repair?
  end

  test "service_type parts" do
    @service_order.service_type = "parts"
    assert @service_order.parts?
  end

  test "service_type upgrade" do
    @service_order.service_type = "upgrade"
    assert @service_order.upgrade?
  end

  test "service_type fitting" do
    @service_order.service_type = "fitting"
    assert @service_order.fitting?
  end

  test "service_type frame_change" do
    @service_order.service_type = "frame_change"
    assert @service_order.frame_change?
  end

  test "invalid service_type raises ArgumentError" do
    assert_raises(ArgumentError) do
      @service_order.service_type = "wash"
    end
  end

  test "service_type is required" do
    @service_order.service_type = nil
    assert_not @service_order.valid?
    assert_includes @service_order.errors[:service_type], "can't be blank"
  end

  # --- status enum ---

  test "default status is received" do
    order = ServiceOrder.new(bicycle: @bicycle, service_type: "repair")
    assert_equal "received", order.status
  end

  test "status received" do
    @service_order.status = "received"
    assert @service_order.received?
  end

  test "status diagnosis" do
    @service_order.status = "diagnosis"
    assert @service_order.diagnosis?
  end

  test "status in_progress" do
    @service_order.status = "in_progress"
    assert @service_order.in_progress?
  end

  test "status completed" do
    @service_order.status = "completed"
    assert @service_order.completed?
  end

  test "status delivered" do
    @service_order.status = "delivered"
    assert @service_order.delivered?
  end

  test "invalid status raises ArgumentError" do
    assert_raises(ArgumentError) do
      @service_order.status = "cancelled"
    end
  end

  # --- cost validations ---

  test "estimated_cost allows nil" do
    @service_order.estimated_cost = nil
    assert @service_order.valid?
  end

  test "estimated_cost must be non-negative" do
    @service_order.estimated_cost = -1
    assert_not @service_order.valid?
    assert_includes @service_order.errors[:estimated_cost], "must be greater than or equal to 0"
  end

  test "estimated_cost allows zero" do
    @service_order.estimated_cost = 0
    assert @service_order.valid?
  end

  test "final_cost allows nil" do
    @service_order.final_cost = nil
    assert @service_order.valid?
  end

  test "final_cost must be non-negative" do
    @service_order.final_cost = -1
    assert_not @service_order.valid?
    assert_includes @service_order.errors[:final_cost], "must be greater than or equal to 0"
  end

  test "final_cost allows zero" do
    @service_order.final_cost = 0
    assert @service_order.valid?
  end

  # --- optional fields ---

  test "expected_completion is optional" do
    @service_order.expected_completion = nil
    assert @service_order.valid?
  end

  test "completed_at is optional" do
    @service_order.completed_at = nil
    assert @service_order.valid?
  end

  test "delivered_at is optional" do
    @service_order.delivered_at = nil
    assert @service_order.valid?
  end

  test "diagnosis_note is optional" do
    @service_order.diagnosis_note = nil
    assert @service_order.valid?
  end

  test "work_note is optional" do
    @service_order.work_note = nil
    assert @service_order.valid?
  end

  # --- Bicycle has_many service_orders ---

  test "bicycle has many service_orders" do
    road_bike = bicycles(:road_bike)
    assert_includes road_bike.service_orders, service_orders(:overhaul_order)
    assert_includes road_bike.service_orders, service_orders(:completed_order)
  end

  test "destroying bicycle destroys associated service_orders" do
    gravel_bike = bicycles(:gravel_bike)
    order_id = service_orders(:repair_order).id
    gravel_bike.destroy
    assert_not ServiceOrder.exists?(order_id)
  end

  # --- Customer has_many service_orders through bicycles ---

  test "customer has many service_orders through bicycles" do
    customer = customers(:one)
    assert_includes customer.service_orders, service_orders(:overhaul_order)
    assert_includes customer.service_orders, service_orders(:completed_order)
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "TB-2026-0001", service_orders(:overhaul_order).order_number
    assert_equal "overhaul", service_orders(:overhaul_order).service_type
    assert_equal "received", service_orders(:overhaul_order).status

    assert_equal "TB-2026-0002", service_orders(:repair_order).order_number
    assert_equal "in_progress", service_orders(:repair_order).status

    assert_equal "TB-2026-0003", service_orders(:completed_order).order_number
    assert_equal "completed", service_orders(:completed_order).status
    assert_not_nil service_orders(:completed_order).completed_at

    assert_equal "TB-2025-0001", service_orders(:delivered_order).order_number
    assert_equal "delivered", service_orders(:delivered_order).status
    assert_not_nil service_orders(:delivered_order).delivered_at
  end
end
