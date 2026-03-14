class ServiceProgress < ApplicationRecord
  # Associations
  belongs_to :service_order

  # Enums
  enum :entry_type, {
    status_change: "status_change",
    manual_update: "manual_update"
  }

  enum :review_state, {
    none: "none",
    under_review: "under_review",
    approval_needed: "approval_needed",
    confirmed: "confirmed"
  }, prefix: true

  # Validations
  validates :from_status, presence: true
  validates :to_status, presence: true
  validates :changed_at, presence: true
  validates :entry_type, presence: true
  validates :review_state, presence: true
  validates :title, presence: true, if: :manual_update?

  # Callbacks
  before_validation :set_defaults
  before_validation :set_changed_at, on: :create
  after_create_commit :broadcast_portal_update, if: :manual_update_broadcastable?

  # Scopes
  scope :chronological, -> { order(changed_at: :asc) }
  scope :reverse_chronological, -> { order(changed_at: :desc) }
  scope :customer_visible, -> { where(customer_visible: true) }

  # Status label mapping (Korean)
  STATUS_LABELS = {
    "received" => "접수",
    "diagnosis" => "진단",
    "in_progress" => "작업중",
    "completed" => "완료",
    "delivered" => "출고"
  }.freeze

  STATUS_CHANGE_TITLES = {
    "received" => "정비 접수가 완료되었어요",
    "diagnosis" => "정비 전 점검을 시작했어요",
    "in_progress" => "정비 작업을 진행하고 있어요",
    "completed" => "정비 작업이 완료되었어요",
    "delivered" => "자전거 출고가 완료되었어요"
  }.freeze

  REVIEW_STATE_LABELS = {
    "none" => nil,
    "under_review" => "검토중",
    "approval_needed" => "확정 전",
    "confirmed" => "확정됨"
  }.freeze

  def from_status_label
    STATUS_LABELS[from_status] || from_status&.titleize
  end

  def to_status_label
    STATUS_LABELS[to_status] || to_status&.titleize
  end

  def display_title
    title.presence || STATUS_CHANGE_TITLES[to_status] || to_status_label
  end

  def review_state_label
    REVIEW_STATE_LABELS[review_state]
  end

  def status_transition?
    from_status != to_status
  end

  def detailed_update?
    note.present? || work_summary.present? || cost_summary.present?
  end

  private

  def set_defaults
    self.entry_type ||= inferred_entry_type
    self.review_state ||= "none"
    self.customer_visible = true if customer_visible.nil?
    self.title = STATUS_CHANGE_TITLES[to_status] if title.blank? && status_change?
  end

  def set_changed_at
    self.changed_at ||= Time.current
  end

  def inferred_entry_type
    from_status == to_status ? "manual_update" : "status_change"
  end

  def manual_update_broadcastable?
    manual_update? && customer_visible?
  end

  def broadcast_portal_update
    service_order.broadcast_replace_to(
      service_order,
      target: ActionView::RecordIdentifier.dom_id(service_order),
      partial: "portal/service_orders/service_order_detail",
      locals: { service_order: service_order }
    )
  end
end
