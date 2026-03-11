class ServiceProgress < ApplicationRecord
  # Associations
  belongs_to :service_order

  # Validations
  validates :from_status, presence: true
  validates :to_status, presence: true
  validates :changed_at, presence: true

  # Callbacks
  before_validation :set_changed_at, on: :create

  # Scopes
  scope :chronological, -> { order(changed_at: :asc) }
  scope :reverse_chronological, -> { order(changed_at: :desc) }

  # Status label mapping (Korean)
  STATUS_LABELS = {
    "received" => "접수",
    "diagnosis" => "진단",
    "in_progress" => "작업중",
    "completed" => "완료",
    "delivered" => "출고"
  }.freeze

  def from_status_label
    STATUS_LABELS[from_status] || from_status&.titleize
  end

  def to_status_label
    STATUS_LABELS[to_status] || to_status&.titleize
  end

  private

  def set_changed_at
    self.changed_at ||= Time.current
  end
end
