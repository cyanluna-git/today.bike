class ServicePhoto < ApplicationRecord
  # Associations
  belongs_to :service_order
  has_one_attached :image

  # Enums
  enum :photo_type, {
    before: "before",
    during: "during",
    after: "after",
    diagnosis: "diagnosis"
  }

  # Validations
  validates :photo_type, presence: true

  validate :acceptable_image

  # Scopes
  scope :ordered, -> { order(taken_at: :desc, created_at: :desc) }

  # Constants for display labels
  PHOTO_TYPE_LABELS = {
    "before" => "정비 전",
    "during" => "정비 중",
    "after" => "정비 후",
    "diagnosis" => "진단"
  }.freeze

  def type_label
    PHOTO_TYPE_LABELS[photo_type] || photo_type&.titleize
  end

  def thumbnail
    image.variant(resize_to_limit: [300, 300])
  end

  private

  def acceptable_image
    return unless image.attached?

    unless image.content_type.in?(%w[image/jpeg image/png image/webp image/heic])
      errors.add(:image, "must be JPEG, PNG, WebP, or HEIC format")
    end

    if image.blob.byte_size > 10.megabytes
      errors.add(:image, "must be less than 10MB")
    end
  end
end
