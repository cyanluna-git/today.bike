module Portal
  class ServiceOrdersController < BaseController
    def index
      @service_orders = current_customer
        .service_orders
        .includes(bicycle: :customer)
        .order(received_at: :desc)
    end

    def show
      @service_order = current_customer
        .service_orders
        .includes(:bicycle, :service_progresses, :service_photos, :repair_logs, :parts_replacements)
        .find(params[:id])
    end
  end
end
