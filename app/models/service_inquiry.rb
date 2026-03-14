class ServiceInquiry < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :customer, optional: true
  belongs_to :bicycle, optional: true
  belongs_to :service_order, optional: true

  enum :status, {
    pending: "pending",
    in_review: "in_review",
    responded: "responded"
  }

  enum :conversion_status, {
    unlinked: "unlinked",
    customer_linked: "customer_linked",
    bicycle_linked: "bicycle_linked",
    service_order_linked: "service_order_linked",
    closed: "closed"
  }

  enum :request_category, {
    general: "general",
    service_request: "service_request",
    fitting_consultation: "fitting_consultation",
    product_inquiry: "product_inquiry"
  }

  STATUS_LABELS = {
    "pending" => "신규",
    "in_review" => "확인중",
    "responded" => "응답완료"
  }.freeze

  CATEGORY_LABELS = {
    "general" => "일반 문의",
    "service_request" => "서비스 문의",
    "fitting_consultation" => "피팅 상담",
    "product_inquiry" => "상품 문의"
  }.freeze

  CONVERSION_STATUS_LABELS = {
    "unlinked" => "미연결",
    "customer_linked" => "고객 연결",
    "bicycle_linked" => "자전거 연결",
    "service_order_linked" => "서비스오더 연결",
    "closed" => "종료"
  }.freeze

  SERVICE_TYPE_LABELS = {
    "overhaul" => "분해정비",
    "repair" => "수리",
    "fitting" => "피팅",
    "upgrade" => "업그레이드"
  }.freeze

  validates :name, presence: true
  validates :phone, presence: true,
                    format: { with: /\A01[016789]-?\d{3,4}-?\d{4}\z/,
                              message: "는 올바른 한국 휴대폰 번호 형식이어야 합니다" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :message, presence: true
  validates :status, presence: true
  validates :conversion_status, presence: true
  validates :request_category, presence: true
  validates :service_type, inclusion: { in: SERVICE_TYPE_LABELS.keys }, allow_blank: true

  before_validation :infer_request_category
  before_save :stamp_responded_at

  scope :recent, -> { order(created_at: :desc) }

  def status_label
    STATUS_LABELS[status] || status&.titleize
  end

  def request_category_label
    CATEGORY_LABELS[request_category] || request_category&.titleize
  end

  def service_type_label
    SERVICE_TYPE_LABELS[service_type] || service_type&.titleize
  end

  def conversion_status_label
    CONVERSION_STATUS_LABELS[conversion_status] || conversion_status&.titleize
  end

  def available_conversion_statuses
    statuses = [ inferred_conversion_status ]
    statuses << "closed" if customer.present?
    statuses.uniq
  end

  def progress_step_status
    inferred_conversion_status
  end

  def customer_candidates
    return Customer.none if normalized_phone.blank?

    Customer.where(
      "REPLACE(REPLACE(phone, '-', ''), ' ', '') = ?",
      normalized_phone
    ).order(:name)
  end

  def source_label
    return "상품 상세" if product.present?
    return "#{service_type_label} 페이지" if service_type.present?
    return "홈" if source_page == "home"
    return "공개 페이지" if source_page.present?

    "직접 문의"
  end

  def customer_prefill_attributes
    {
      name: name,
      phone: phone,
      email: email,
      memo: customer_prefill_memo,
      active: true
    }
  end

  def link_customer!(linked_customer)
    self.customer = linked_customer
    self.conversion_status = inferred_conversion_status
    save!
  end

  def bicycle_prefill_attributes
    {
      customer_id: customer_id
    }.compact
  end

  def link_bicycle!(linked_bicycle)
    self.customer ||= linked_bicycle.customer
    self.bicycle = linked_bicycle
    self.conversion_status = inferred_conversion_status
    save!
  end

  def service_order_prefill_attributes
    {
      bicycle_id: bicycle_id,
      service_type: service_type.presence_in(ServiceOrder.service_types.keys),
      diagnosis_note: service_order_intake_summary
    }.compact
  end

  def link_service_order!(linked_service_order)
    self.customer ||= linked_service_order.customer
    self.bicycle ||= linked_service_order.bicycle
    self.service_order = linked_service_order
    self.conversion_status = inferred_conversion_status
    save!
  end

  def unlink_service_order!
    self.service_order = nil
    self.conversion_status = inferred_conversion_status
    save!
  end

  def unlink_bicycle!
    self.service_order = nil
    self.bicycle = nil
    self.conversion_status = inferred_conversion_status
    save!
  end

  def unlink_customer!
    self.service_order = nil
    self.bicycle = nil
    self.customer = nil
    self.conversion_status = inferred_conversion_status
    save!
  end

  private

  def normalized_phone
    phone.to_s.gsub(/\D/, "")
  end

  def infer_request_category
    self.request_category =
      if product_id.present?
        "product_inquiry"
      elsif service_type == "fitting"
        "fitting_consultation"
      elsif service_type.present?
        "service_request"
      else
        "general"
      end
  end

  def customer_prefill_memo
    lines = [
      "문의 접수에서 생성된 고객",
      "문의일: #{(created_at || Time.current).strftime('%Y-%m-%d %H:%M')}",
      "유입: #{source_label}"
    ]

    lines << "서비스: #{service_type_label}" if service_type.present?
    lines << "희망 방문일: #{desired_visit_on}" if desired_visit_on.present?
    lines << "문의 요약: #{message.to_s.squish.truncate(120)}"

    lines.join("\n")
  end

  def service_order_intake_summary
    lines = [
      "[문의 접수 전환]",
      "문의일: #{(created_at || Time.current).strftime('%Y-%m-%d %H:%M')}",
      "유입: #{source_label}"
    ]

    lines << "희망 방문일: #{desired_visit_on}" if desired_visit_on.present?
    lines << "문의 요약: #{message.to_s.squish.truncate(160)}"

    lines.join("\n")
  end

  def stamp_responded_at
    self.responded_at = Time.current if responded? && responded_at.blank?
    self.responded_at = nil unless responded?
  end

  validate :conversion_status_matches_linkage
  validate :linked_entities_are_consistent

  def conversion_status_matches_linkage
    return if conversion_status.blank?

    if closed?
      errors.add(:conversion_status, "requires a linked customer before closing") if customer.blank?
      return
    end

    expected_status = inferred_conversion_status
    return if conversion_status == expected_status

    errors.add(:conversion_status, "must match the currently linked entities")
  end

  def linked_entities_are_consistent
    if bicycle.present? && customer.blank?
      errors.add(:customer, "must be linked before linking a bicycle")
    end

    if bicycle.present? && customer.present? && bicycle.customer != customer
      errors.add(:bicycle, "must belong to the linked customer")
    end

    if service_order.present? && bicycle.blank?
      errors.add(:bicycle, "must be linked before linking a service order")
    end

    if service_order.present? && bicycle.present? && service_order.bicycle != bicycle
      errors.add(:service_order, "must belong to the linked bicycle")
    end

    if service_order.present? && customer.present? && service_order.customer != customer
      errors.add(:service_order, "must belong to the linked customer")
    end
  end

  def inferred_conversion_status
    return "service_order_linked" if service_order.present?
    return "bicycle_linked" if bicycle.present?
    return "customer_linked" if customer.present?

    "unlinked"
  end
end
