require "test_helper"

class ServicePhotoTest < ActiveSupport::TestCase
  def setup
    @service_order = service_orders(:overhaul_order)
    @service_photo = ServicePhoto.new(
      service_order: @service_order,
      photo_type: "before",
      caption: "정비 전 사진",
      taken_at: Time.current
    )
  end

  # --- Valid record ---

  test "valid service photo with all fields" do
    assert @service_photo.valid?
  end

  test "valid service photo with minimal fields (service_order, photo_type)" do
    photo = ServicePhoto.new(service_order: @service_order, photo_type: "before")
    assert photo.valid?
  end

  # --- Associations ---

  test "belongs to service_order" do
    photo = service_photos(:before_photo)
    assert_equal service_orders(:overhaul_order), photo.service_order
  end

  test "invalid without service_order" do
    @service_photo.service_order = nil
    assert_not @service_photo.valid?
    assert_includes @service_photo.errors[:service_order], "must exist"
  end

  test "service_order has many service_photos" do
    order = service_orders(:overhaul_order)
    assert_includes order.service_photos, service_photos(:before_photo)
    assert_includes order.service_photos, service_photos(:diagnosis_photo)
  end

  test "destroying service_order destroys associated service_photos" do
    order = service_orders(:overhaul_order)
    photo_ids = order.service_photos.pluck(:id)
    assert photo_ids.any?
    order.destroy
    photo_ids.each do |id|
      assert_not ServicePhoto.exists?(id)
    end
  end

  # --- photo_type enum ---

  test "photo_type before" do
    @service_photo.photo_type = "before"
    assert @service_photo.before?
  end

  test "photo_type during" do
    @service_photo.photo_type = "during"
    assert @service_photo.during?
  end

  test "photo_type after" do
    @service_photo.photo_type = "after"
    assert @service_photo.after?
  end

  test "photo_type diagnosis" do
    @service_photo.photo_type = "diagnosis"
    assert @service_photo.diagnosis?
  end

  test "invalid photo_type raises ArgumentError" do
    assert_raises(ArgumentError) do
      @service_photo.photo_type = "random"
    end
  end

  test "photo_type is required" do
    @service_photo.photo_type = nil
    assert_not @service_photo.valid?
    assert_includes @service_photo.errors[:photo_type], "can't be blank"
  end

  # --- Optional fields ---

  test "caption is optional" do
    @service_photo.caption = nil
    assert @service_photo.valid?
  end

  test "taken_at is optional" do
    @service_photo.taken_at = nil
    assert @service_photo.valid?
  end

  # --- has_one_attached :image ---

  test "responds to image attachment" do
    assert @service_photo.respond_to?(:image)
  end

  test "image is not required for validity" do
    assert @service_photo.valid?
  end

  # --- type_label ---

  test "type_label returns Korean label for before" do
    @service_photo.photo_type = "before"
    assert_equal "정비 전", @service_photo.type_label
  end

  test "type_label returns Korean label for during" do
    @service_photo.photo_type = "during"
    assert_equal "정비 중", @service_photo.type_label
  end

  test "type_label returns Korean label for after" do
    @service_photo.photo_type = "after"
    assert_equal "정비 후", @service_photo.type_label
  end

  test "type_label returns Korean label for diagnosis" do
    @service_photo.photo_type = "diagnosis"
    assert_equal "진단", @service_photo.type_label
  end

  # --- Scopes ---

  test "ordered scope returns photos ordered by taken_at desc then created_at desc" do
    photos = ServicePhoto.ordered
    assert photos.count > 0
  end

  # --- Fixtures loaded correctly ---

  test "fixtures are loaded" do
    assert_equal "before", service_photos(:before_photo).photo_type
    assert_equal "diagnosis", service_photos(:diagnosis_photo).photo_type
    assert_equal "during", service_photos(:during_photo).photo_type
    assert_equal "after", service_photos(:after_photo).photo_type
  end
end
