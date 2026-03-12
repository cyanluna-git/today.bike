class KakaoNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification
    return if notification.sent? || notification.skipped?

    customer = notification.customer

    unless customer.phone.present?
      notification.mark_skipped!("Customer has no phone number")
      return
    end

    service = KakaoAlimtalkService.new(
      customer: customer,
      template_code: notification.notification_type.to_sym,
      variables: extract_variables(notification)
    )

    result = service.send!

    if result[:success]
      notification.mark_sent!
    else
      notification.mark_failed!(result[:error])
    end
  end

  private

  def extract_variables(notification)
    vars = { customer_name: notification.customer.name }

    if notification.service_order.present?
      bicycle = notification.service_order.bicycle
      vars[:bicycle_name] = "#{bicycle.brand} #{bicycle.model_label}"
      vars[:status] = notification.service_order.status
    end

    vars
  end
end
