require "test_helper"

class FittingRecordTest < ActiveSupport::TestCase
  def setup
    @bicycle = bicycles(:road_bike)
    @fitting_record = FittingRecord.new(
      bicycle: @bicycle,
      saddle_height: 720.0,
      saddle_setback: 50.0,
      saddle_tilt: -1.0,
      saddle_brand: "Fizik",
      saddle_model: "Arione R3",
      handlebar_width: 420.0,
      stem_length: 110.0,
      crank_length: 172.5,
      notes: "테스트 피팅"
    )
  end

  # --- Valid record ---

  test "valid fitting record with all fields" do
    assert @fitting_record.valid?
  end

  test "valid with minimal fields (bicycle + saddle_height)" do
    record = FittingRecord.new(bicycle: @bicycle, saddle_height: 700.0)
    assert record.valid?
  end

  # --- Validations ---

  test "invalid without bicycle" do
    @fitting_record.bicycle = nil
    assert_not @fitting_record.valid?
    assert_includes @fitting_record.errors[:bicycle], "must exist"
  end

  test "invalid without saddle_height" do
    @fitting_record.saddle_height = nil
    assert_not @fitting_record.valid?
    assert_includes @fitting_record.errors[:saddle_height], "can't be blank"
  end

  test "recorded_at defaults to current time" do
    @fitting_record.recorded_at = nil
    @fitting_record.valid?
    assert_not_nil @fitting_record.recorded_at
  end

  # --- Associations ---

  test "belongs to bicycle" do
    record = fitting_records(:first_fitting)
    assert_equal bicycles(:road_bike), record.bicycle
  end

  test "service_order is optional" do
    @fitting_record.service_order = nil
    assert @fitting_record.valid?
  end

  test "can belong to service_order" do
    record = fitting_records(:first_fitting)
    assert_equal service_orders(:overhaul_order), record.service_order
  end

  test "bicycle has many fitting records" do
    assert_includes @bicycle.fitting_records, fitting_records(:first_fitting)
    assert_includes @bicycle.fitting_records, fitting_records(:second_fitting)
  end

  test "destroying bicycle destroys fitting records" do
    bicycle = bicycles(:gravel_bike)
    fitting_id = fitting_records(:gravel_fitting).id
    bicycle.destroy
    assert_not FittingRecord.exists?(fitting_id)
  end

  # --- Scopes ---

  test "chronological scope orders by recorded_at descending" do
    records = @bicycle.fitting_records.chronological
    assert_equal fitting_records(:second_fitting), records.first
    assert_equal fitting_records(:first_fitting), records.second
  end

  # --- diff_from method ---

  test "diff_from returns empty hash when comparing to nil" do
    assert_equal({}, @fitting_record.diff_from(nil))
  end

  test "diff_from returns empty hash for identical records" do
    other = @fitting_record.dup
    assert_equal({}, @fitting_record.diff_from(other))
  end

  test "diff_from returns changed measurement fields with deltas" do
    latest = fitting_records(:second_fitting)
    previous = fitting_records(:first_fitting)

    diff = latest.diff_from(previous)

    assert diff.key?(:saddle_height)
    assert_equal 720.0, diff[:saddle_height][:from]
    assert_equal 722.0, diff[:saddle_height][:to]
    assert_equal 2.0, diff[:saddle_height][:delta]
  end

  test "diff_from returns negative deltas" do
    latest = fitting_records(:second_fitting)
    previous = fitting_records(:first_fitting)

    diff = latest.diff_from(previous)

    assert diff.key?(:stem_length)
    assert_equal 110.0, diff[:stem_length][:from]
    assert_equal 100.0, diff[:stem_length][:to]
    assert_equal(-10.0, diff[:stem_length][:delta])
  end

  test "diff_from detects text field changes" do
    latest = fitting_records(:second_fitting)
    previous = fitting_records(:first_fitting)

    diff = latest.diff_from(previous)

    assert diff.key?(:cleat_right)
    assert_equal "중앙 정렬", diff[:cleat_right][:from]
    assert_equal "중앙 정렬, 약간 내측", diff[:cleat_right][:to]
  end

  test "diff_from does not include unchanged fields" do
    latest = fitting_records(:second_fitting)
    previous = fitting_records(:first_fitting)

    diff = latest.diff_from(previous)

    assert_not diff.key?(:handlebar_width)  # both 420.0
    assert_not diff.key?(:crank_length)      # both 172.5
    assert_not diff.key?(:saddle_brand)      # both "Fizik"
  end

  # --- Fixtures ---

  test "fixtures are loaded correctly" do
    first = fitting_records(:first_fitting)
    assert_equal 720.0, first.saddle_height
    assert_equal "Fizik", first.saddle_brand
    assert_equal bicycles(:road_bike), first.bicycle

    second = fitting_records(:second_fitting)
    assert_equal 722.0, second.saddle_height
    assert_nil second.service_order
  end
end
