class Notification < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :service_order, optional: true

  # Enums
  enum :notification_type, {
    status_change: "status_change",
    completion: "completion",
    pickup_ready: "pickup_ready",
    general: "general"
  }

  enum :channel, {
    kakao: "kakao",
    sms: "sms",
    email: "email"
  }

  enum :status, {
    pending: "pending",
    sent: "sent",
    failed: "failed",
    skipped: "skipped"
  }

  # Validations
  validates :notification_type, presence: true
  validates :channel, presence: true
  validates :status, presence: true
  validates :message, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  def mark_sent!
    update!(status: :sent, sent_at: Time.current)
  end

  def mark_failed!(error)
    update!(status: :failed, error_message: error)
  end

  def mark_skipped!(reason = nil)
    update!(status: :skipped, error_message: reason)
  end
end
