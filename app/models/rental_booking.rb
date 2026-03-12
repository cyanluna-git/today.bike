class RentalBooking < ApplicationRecord
  belongs_to :rental
  belongs_to :customer, optional: true

  # Enums
  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    active: "active",
    returned: "returned",
    cancelled: "cancelled"
  }

  STATUS_LABELS = {
    "pending" => "대기",
    "confirmed" => "확정",
    "active" => "이용중",
    "returned" => "반납",
    "cancelled" => "취소"
  }.freeze

  # Validations
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, presence: true
  validate :end_date_after_start_date

  # Callbacks
  before_save :calculate_total_amount

  def status_label
    STATUS_LABELS[status] || status&.titleize
  end

  def days
    return 0 unless start_date && end_date
    (end_date - start_date).to_i
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def calculate_total_amount
    return unless start_date && end_date && rental&.daily_rate
    self.total_amount = rental.daily_rate * days
  end
end
