module Admin
  class DashboardController < BaseController
    def index
      @total_customers = Customer.count
      @total_bicycles = Bicycle.count
      @active_service_orders = ServiceOrder.where.not(status: "delivered").count
      @completed_this_month = ServiceOrder.where(status: "completed")
                                          .where(completed_at: Time.current.beginning_of_month..Time.current.end_of_month)
                                          .count

      @today_completed = ServiceOrder.where(status: %w[completed delivered])
                                     .where(completed_at: Time.current.beginning_of_day..Time.current.end_of_day)
                                     .count
      @today_delivered = ServiceOrder.where(status: "delivered")
                                     .where(delivered_at: Time.current.beginning_of_day..Time.current.end_of_day)
                                     .count

      @status_counts = ServiceOrder.group(:status).count

      @recent_service_orders = ServiceOrder.includes(bicycle: :customer)
                                           .order(created_at: :desc)
                                           .limit(5)
    end
  end
end
