module Admin
  class ServiceOrdersController < BaseController
    before_action :set_service_order, only: %i[show edit update destroy]

    def index
      service_orders = ServiceOrder.includes(bicycle: :customer).order(created_at: :desc)
      service_orders = service_orders.where(status: params[:status]) if params[:status].present?
      @pagy, @service_orders = pagy(service_orders)
    end

    def kanban
      service_orders = ServiceOrder.includes(bicycle: :customer).order(received_at: :desc)
      @columns = ServiceOrder.statuses.map do |key, value|
        { key: key, value: value, orders: service_orders.select { |so| so.status == value } }
      end
    end

    def show
    end

    def new
      @service_order = ServiceOrder.new
      if params[:bicycle_id].present?
        @service_order.bicycle_id = params[:bicycle_id]
        bicycle = Bicycle.find_by(id: params[:bicycle_id])
        @preselected_customer = bicycle&.customer
      elsif params[:customer_id].present?
        @preselected_customer = Customer.find_by(id: params[:customer_id])
      end
    end

    def create
      @service_order = ServiceOrder.new(service_order_params)

      if @service_order.save
        redirect_to admin_service_order_path(@service_order), notice: "Service order was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @service_order.update(service_order_params)
        redirect_to admin_service_order_path(@service_order), notice: "Service order was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @service_order.destroy
      redirect_to admin_service_orders_path, notice: "Service order was successfully deleted."
    end

    private

    def set_service_order
      @service_order = ServiceOrder.includes(:service_progresses, bicycle: :customer).find(params[:id])
    end

    def service_order_params
      params.require(:service_order).permit(
        :bicycle_id, :service_type, :status,
        :expected_completion, :diagnosis_note, :work_note,
        :estimated_cost, :final_cost
      )
    end
  end
end
