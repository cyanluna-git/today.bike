module Portal
  class BicyclesController < BaseController
    def index
      @bicycles = current_customer
        .bicycles
        .includes(:fitting_records, { service_orders: :service_progresses }, photos_attachments: :blob)
        .order(created_at: :desc)
        .to_a

      @service_orders = current_customer
        .service_orders
        .includes(:bicycle, :service_progresses)
        .order(received_at: :desc)
        .to_a

      @active_service_orders = @service_orders.select { |service_order| active_service_order?(service_order) }
      @recent_service_orders = @service_orders.max_by(3) { |service_order| service_order_sort_at(service_order) }
      @recent_fitting_records = current_customer
        .fitting_records
        .includes(:bicycle)
        .order(recorded_at: :desc)
        .limit(3)
        .to_a

      @bicycle_summaries = @bicycles.map do |bicycle|
        active_order = bicycle.service_orders
          .select { |service_order| active_service_order?(service_order) }
          .max_by { |service_order| service_order_update_at(service_order) }
        latest_service_order = bicycle.service_orders.max_by { |service_order| service_order_sort_at(service_order) }
        latest_fitting_record = bicycle.fitting_records.max_by(&:recorded_at)

        {
          bicycle: bicycle,
          active_order: active_order,
          latest_service_order: latest_service_order,
          latest_fitting_record: latest_fitting_record,
          lifecycle_reminder: PortalBicycleLifecycleReminder.new(bicycle).call
        }
      end

      update_feed = PortalUpdateFeed.new(customer: current_customer).all
      @recent_update_at = update_feed.first&.dig(:occurred_at)
      @recent_updates = update_feed.first(3)
    end

    def show
      @bicycle = current_customer.bicycles
        .includes(:bicycle_specs, :fitting_records, { service_orders: :service_progresses })
        .find(params[:id])
      @grouped_specs = @bicycle.grouped_specs
      @lifecycle_reminder = PortalBicycleLifecycleReminder.new(@bicycle).call
    end

    private

    def active_service_order?(service_order)
      !service_order.status.in?(%w[completed delivered])
    end

    def service_order_update_at(service_order)
      service_order.service_progresses.max_by(&:changed_at)&.changed_at ||
        service_order.completed_at ||
        service_order.received_at ||
        service_order.created_at
    end

    def service_order_sort_at(service_order)
      service_order.delivered_at ||
        service_order.completed_at ||
        service_order.received_at ||
        service_order.created_at
    end
  end
end
