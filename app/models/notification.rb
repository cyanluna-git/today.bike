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

  TYPE_LABELS = {
    "status_change" => "정비 상태 안내",
    "completion" => "정비 완료 안내",
    "pickup_ready" => "출고 안내",
    "general" => "일반 안내"
  }.freeze

  def mark_sent!
    update!(status: :sent, sent_at: Time.current)
  end

  def mark_failed!(error)
    update!(status: :failed, error_message: error)
  end

  def mark_skipped!(reason = nil)
    update!(status: :skipped, error_message: reason)
  end

  def display_title
    TYPE_LABELS[notification_type] || notification_type&.titleize || "업데이트"
  end

  def display_timestamp
    sent_at || created_at
  end
end
