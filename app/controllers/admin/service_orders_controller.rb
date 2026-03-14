module Admin
  class ServiceOrdersController < BaseController
    before_action :set_service_order, only: %i[show edit update destroy update_status]
    before_action :set_source_inquiry, only: %i[new create]

    def index
      service_orders = ServiceOrder.includes(bicycle: :customer)
                                    .search(params[:query])
                                    .by_service_type(params[:service_type])
                                    .by_date_range(params[:start_date], params[:end_date])
                                    .order(created_at: :desc)
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

      if @source_inquiry.present?
        @service_order.assign_attributes(@source_inquiry.service_order_prefill_attributes)
        @preselected_customer ||= @source_inquiry.customer || @service_order.bicycle&.customer
      end
    end

    def create
      @service_order = ServiceOrder.new(service_order_params)

      if save_service_order_with_optional_inquiry_link
        if @source_inquiry.present?
          redirect_to admin_service_inquiry_path(@source_inquiry), notice: "서비스오더를 생성하고 문의에 연결했습니다."
        else
          redirect_to admin_service_order_path(@service_order), notice: "Service order was successfully created."
        end
      else
        @preselected_customer ||= @service_order.bicycle&.customer
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

    def update_status
      @old_status = @service_order.status
      new_status = params[:status]

      unless ServiceOrder::STATUS_ORDER.include?(new_status)
        head :unprocessable_entity
        return
      end

      if @service_order.update(status: new_status)
        @new_status = new_status
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to kanban_admin_service_orders_path, notice: "Status updated." }
        end
      else
        head :unprocessable_entity
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.includes(:service_progresses, :service_photos, :repair_logs, :parts_replacements, bicycle: :customer).find(params[:id])
    end

    def set_source_inquiry
      @source_inquiry = ServiceInquiry.find_by(id: params[:service_inquiry_id])
    end

    def save_service_order_with_optional_inquiry_link
      ActiveRecord::Base.transaction do
        @service_order.save!
        @source_inquiry&.link_service_order!(@service_order)
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
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
