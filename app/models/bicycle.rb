class Bicycle < ApplicationRecord
  # Associations
  belongs_to :customer
  has_many :bicycle_specs, dependent: :destroy
  has_many :fitting_records, dependent: :destroy
  has_many :service_orders, dependent: :destroy
  has_many_attached :photos

  # Enums
  enum :bike_type, { road: "road", mtb: "mtb", gravel: "gravel", hybrid: "hybrid", other: "other" }
  enum :status, { active: "active", sold: "sold", scrapped: "scrapped" }

  # Scopes
  scope :search, ->(query) {
    return all if query.blank?
    where("brand LIKE :q OR model_label LIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

  # Validations
  validates :brand, presence: true
  validates :model_label, presence: true
  validates :frame_number, uniqueness: true, allow_nil: true
  validates :bike_type, presence: true
  validates :status, presence: true

  validate :acceptable_photos

  # Returns specs grouped by category, preserving CATEGORY_GROUPS order.
  # Only includes categories that have at least one spec.
  def grouped_specs
    specs_by_category = bicycle_specs.group_by(&:category)
    BicycleSpec::CATEGORY_GROUPS.each_with_object({}) do |(key, group), result|
      specs = specs_by_category[key]
      next unless specs&.any?
      result[key] = { label: group[:label], specs: specs.sort_by { |s| group[:components].index(s.component) || 999 } }
    end
  end

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
