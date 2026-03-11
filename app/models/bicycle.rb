class Bicycle < ApplicationRecord
  # Associations
  belongs_to :customer

  # Enums
  enum :bike_type, { road: "road", mtb: "mtb", gravel: "gravel", hybrid: "hybrid", other: "other" }
  enum :status, { active: "active", sold: "sold", scrapped: "scrapped" }

  # Validations
  validates :brand, presence: true
  validates :model_label, presence: true
  validates :frame_number, uniqueness: true, allow_nil: true
  validates :bike_type, presence: true
  validates :status, presence: true
end
