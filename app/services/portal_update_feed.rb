class PortalUpdateFeed
  def initialize(customer:)
    @customer = customer
  end

  def all
    (service_progress_items + notification_items).sort_by { |item| item[:occurred_at] }.reverse
  end

  private

  attr_reader :customer

  def service_progress_items
    ServiceProgress
      .customer_visible
      .joins(:service_order)
      .where(service_order: customer.service_orders)
      .includes(service_order: :bicycle)
      .map do |progress|
        {
          kind: :service_progress,
          title: progress.display_title,
          body: progress.note.presence || progress.work_summary.presence || progress.cost_summary.presence,
          occurred_at: progress.changed_at,
          link: progress.service_order.present? ? Rails.application.routes.url_helpers.portal_service_order_path(progress.service_order) : nil,
          service_order: progress.service_order,
          bicycle: progress.service_order&.bicycle,
          badge_label: progress.manual_update? ? "업데이트" : "상태 변경",
          review_label: progress.review_state_label
        }
      end
  end

  def notification_items
    customer.notifications.includes(service_order: :bicycle).recent.map do |notification|
      {
        kind: :notification,
        title: notification.display_title,
        body: notification.message,
        occurred_at: notification.display_timestamp,
        link: notification.service_order.present? ? Rails.application.routes.url_helpers.portal_service_order_path(notification.service_order) : nil,
        service_order: notification.service_order,
        bicycle: notification.service_order&.bicycle,
        badge_label: "알림",
        review_label: nil
      }
    end
  end
end
