class PortalBicycleLifecycleReminder
  SERVICE_CHECK_DAYS = 180
  FITTING_CHECK_DAYS = 365

  def initialize(bicycle, today: Time.zone.today)
    @bicycle = bicycle
    @today = today
  end

  def call
    return inactive_bicycle_reminder unless bicycle.active?
    return active_service_reminder if active_service_order.present?
    return first_record_reminder if latest_service_date.blank? && latest_fitting_date.blank?
    return service_due_reminder if latest_service_date.blank? || days_since(latest_service_date) >= SERVICE_CHECK_DAYS
    return fitting_due_reminder if fitting_due?

    recent_care_reminder
  end

  private

  attr_reader :bicycle, :today

  def active_service_order
    @active_service_order ||= bicycle.service_orders
      .reject { |service_order| service_order.status.in?(%w[completed delivered]) }
      .max_by { |service_order| service_order_updated_at(service_order) }
  end

  def latest_service_order
    @latest_service_order ||= bicycle.service_orders.max_by { |service_order| service_order_sorted_at(service_order) }
  end

  def latest_service_date
    @latest_service_date ||= latest_service_order&.completed_at&.to_date ||
      latest_service_order&.received_at&.to_date ||
      latest_service_order&.created_at&.to_date
  end

  def latest_fitting_record
    @latest_fitting_record ||= bicycle.fitting_records.max_by(&:recorded_at)
  end

  def latest_fitting_date
    @latest_fitting_date ||= latest_fitting_record&.recorded_at&.to_date
  end

  def fitting_due?
    return true if latest_fitting_date.blank? && bicycle.bike_type.in?(%w[road gravel])
    return false if latest_fitting_date.blank?

    days_since(latest_fitting_date) >= FITTING_CHECK_DAYS
  end

  def inactive_bicycle_reminder
    reminder(
      tone: :neutral,
      badge: "보관 아님",
      title: "현재 보관 중인 자전거가 아닙니다.",
      body: "판매 또는 폐차 상태로 표시되어 있어 과거 기록 위주로 확인하는 보수적인 안내만 제공합니다."
    )
  end

  def active_service_reminder
    reminder(
      tone: :info,
      badge: "진행 중",
      title: "현재 정비가 진행 중입니다.",
      body: "이번 작업 흐름을 먼저 확인해보세요. 상세 화면에서 최근 업데이트와 이전 관리 기록을 함께 볼 수 있습니다."
    )
  end

  def first_record_reminder
    reminder(
      tone: :calm,
      badge: "기록 시작",
      title: "첫 관리 기록을 남겨두면 좋아요.",
      body: "아직 정비나 피팅 기록이 없어 보수적인 안내만 제공합니다. 한 번 기록이 쌓이면 이후 변화 비교가 훨씬 쉬워집니다."
    )
  end

  def service_due_reminder
    title =
      if latest_service_date.present?
        "최근 정비 이후 시간이 조금 지났어요."
      else
        "최근 정비 기록이 아직 없어요."
      end

    body =
      if latest_service_date.present?
        "마지막 정비가 #{days_since(latest_service_date)}일 전입니다. 최근 주행감이 달라졌다면 상태를 다시 점검해보는 편이 안전합니다."
      else
        "포털에 남은 정비 기록이 아직 없습니다. 현재 상태를 한 번 점검해두면 이후 관리 이력이 더 선명해집니다."
      end

    reminder(
      tone: :attention,
      badge: "점검 권장",
      title: title,
      body: body
    )
  end

  def fitting_due_reminder
    title =
      if latest_fitting_date.present?
        "세팅 기록을 다시 확인해보면 좋아요."
      else
        "피팅 기록을 남겨두면 좋아요."
      end

    body =
      if latest_fitting_date.present?
        "최근 피팅이 #{days_since(latest_fitting_date)}일 전입니다. 안장 높이, 스템 길이, 클릿 위치 같은 세팅은 시간이 지나며 달라질 수 있습니다."
      else
        "피팅 기록이 아직 없습니다. 현재 자세와 세팅을 한 번 남겨두면 다음 조정 때 비교가 쉬워집니다."
      end

    reminder(
      tone: :calm,
      badge: "세팅 확인",
      title: title,
      body: body
    )
  end

  def recent_care_reminder
    reminder(
      tone: :positive,
      badge: "관리 양호",
      title: "최근 관리 기록이 잘 반영돼 있어요.",
      body: "최근 정비와 피팅 기록이 비교적 가까운 시점에 남아 있습니다. 필요할 때 상세 화면에서 흐름을 다시 확인해보세요."
    )
  end

  def reminder(tone:, badge:, title:, body:)
    {
      tone: tone,
      badge: badge,
      title: title,
      body: body,
      highlights: reminder_highlights
    }
  end

  def reminder_highlights
    highlights = []
    highlights << highlight_line("최근 정비", latest_service_date)
    highlights << highlight_line("최근 피팅", latest_fitting_date)
    highlights
  end

  def highlight_line(label, date)
    date_text = date.present? ? date.strftime("%Y.%m.%d") : "기록 없음"
    "#{label} #{date_text}"
  end

  def days_since(date)
    (today - date).to_i
  end

  def service_order_updated_at(service_order)
    service_order.service_progresses.max_by(&:changed_at)&.changed_at ||
      service_order.completed_at ||
      service_order.received_at ||
      service_order.created_at
  end

  def service_order_sorted_at(service_order)
    service_order.delivered_at ||
      service_order.completed_at ||
      service_order.received_at ||
      service_order.created_at
  end
end
