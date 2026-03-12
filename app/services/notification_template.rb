class NotificationTemplate
  TEMPLATES = {
    status_change: "{customer_name}님, {bicycle_name} 정비 상태가 '{status}'(으)로 변경되었습니다.",
    completion: "{customer_name}님, {bicycle_name} 정비가 완료되었습니다. 픽업 가능합니다.",
    pickup_ready: "{customer_name}님, {bicycle_name} 출고 준비가 완료되었습니다."
  }.freeze

  STATUS_LABELS = {
    "received" => "접수",
    "diagnosis" => "진단",
    "in_progress" => "작업중",
    "completed" => "완료",
    "delivered" => "출고"
  }.freeze

  def self.render(template_key, variables = {})
    template = TEMPLATES[template_key.to_sym]
    raise ArgumentError, "Unknown template: #{template_key}" unless template

    # Convert status to Korean label if present
    if variables[:status].present? && STATUS_LABELS.key?(variables[:status])
      variables = variables.merge(status: STATUS_LABELS[variables[:status]])
    end

    result = template.dup
    variables.each do |key, value|
      result.gsub!("{#{key}}", value.to_s)
    end
    result
  end

  def self.template_keys
    TEMPLATES.keys
  end

  def self.template_for(key)
    TEMPLATES[key.to_sym]
  end
end
