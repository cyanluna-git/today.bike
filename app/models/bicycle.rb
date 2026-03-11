class Bicycle < ApplicationRecord
  # Associations
  belongs_to :customer
  has_many_attached :photos

  # Enums
  enum :bike_type, { road: "road", mtb: "mtb", gravel: "gravel", hybrid: "hybrid", other: "other" }
  enum :status, { active: "active", sold: "sold", scrapped: "scrapped" }

  # Validations
  validates :brand, presence: true
  validates :model_label, presence: true
  validates :frame_number, uniqueness: true, allow_nil: true
  validates :bike_type, presence: true
  validates :status, presence: true

  validate :acceptable_photos

  # Photo thumbnail variant
  def photo_thumbnail(photo)
    photo.variant(resize_to_limit: [ 300, 300 ])
  end

  private

  def acceptable_photos
    return unless photos.attached?

    photos.each do |photo|
      unless photo.content_type.in?(%w[image/jpeg image/png image/webp image/heic])
        errors.add(:photos, "must be JPEG, PNG, WebP, or HEIC format")
      end

      if photo.blob.byte_size > 10.megabytes
        errors.add(:photos, "must be less than 10MB each")
      end
    end

    if photos.count > 10
      errors.add(:photos, "cannot exceed 10 photos")
    end
  end
end
