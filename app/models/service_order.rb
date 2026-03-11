class ServiceOrder < ApplicationRecord
  # Associations
  belongs_to :bicycle
  has_one :customer, through: :bicycle

  # Enums
  enum :service_type, {
    overhaul: "overhaul",
    repair: "repair",
    parts: "parts",
    upgrade: "upgrade",
    fitting: "fitting",
    frame_change: "frame_change"
  }

  enum :status, {
    received: "received",
    diagnosis: "diagnosis",
    in_progress: "in_progress",
    completed: "completed",
    delivered: "delivered"
  }

  # Callbacks
  before_create :generate_order_number
  before_create :set_received_at

  # Validations
  validates :order_number, uniqueness: true, allow_nil: true
  validates :service_type, presence: true
  validates :status, presence: true
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :final_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  private

  def generate_order_number
    current_year = Time.current.year
    prefix = "TB-#{current_year}-"

    max_order = ServiceOrder
      .where("order_number LIKE ?", "#{prefix}%")
      .order(order_number: :desc)
      .pick(:order_number)

    next_sequence = if max_order
      max_order.last(4).to_i + 1
    else
      1
    end

    self.order_number = format("%s%04d", prefix, next_sequence)
  end

  def set_received_at
    self.received_at ||= Time.current
  end
end
