class Rental < ApplicationRecord
  has_many_attached :images
  has_many :rental_bookings, dependent: :destroy

  # Enums
  enum :rental_type, {
    road: "road",
    mtb: "mtb",
    gravel: "gravel",
    ebike: "ebike",
    other: "other"
  }

  RENTAL_TYPE_LABELS = {
    "road" => "로드",
    "mtb" => "MTB",
    "gravel" => "그래벨",
    "ebike" => "전기자전거",
    "other" => "기타"
  }.freeze

  # Validations
  validates :name, presence: true
  validates :daily_rate, presence: true, numericality: { greater_than: 0 }
  validates :rental_type, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { type.present? ? where(rental_type: type) : all }

  def rental_type_label
    RENTAL_TYPE_LABELS[rental_type] || rental_type&.titleize
  end

  # Returns dates that are booked (confirmed or active bookings)
  def booked_dates
    rental_bookings.where(status: %w[confirmed active])
      .flat_map { |b| (b.start_date..b.end_date).to_a }
      .uniq
  end

  def available_on?(start_date, end_date)
    rental_bookings
      .where(status: %w[confirmed active])
      .where("start_date <= ? AND end_date >= ?", end_date, start_date)
      .none?
  end
end
