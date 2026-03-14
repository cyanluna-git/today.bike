module Admin
  class ServiceInquiriesController < BaseController
    before_action :set_service_inquiry, only: %i[show update link_customer link_bicycle unlink_linkage]

    def index
      inquiries = ServiceInquiry.includes(:product, :customer, :bicycle, :service_order).recent
      inquiries = inquiries.where(status: params[:status]) if params[:status].present?
      @pagy, @service_inquiries = pagy(inquiries)
    end

    def show
    end

    def update
      if @service_inquiry.update(service_inquiry_params)
        redirect_to admin_service_inquiry_path(@service_inquiry), notice: "문의 상태가 업데이트되었습니다."
      else
        render :show, status: :unprocessable_entity
      end
    end

    def link_customer
      customer = Customer.find(params.require(:customer_id))
      @service_inquiry.link_customer!(customer)
      redirect_to admin_service_inquiry_path(@service_inquiry), notice: "기존 고객을 문의에 연결했습니다."
    rescue ActiveRecord::RecordInvalid
      redirect_to admin_service_inquiry_path(@service_inquiry), alert: @service_inquiry.errors.full_messages.to_sentence
    end

    def link_bicycle
      raise ActiveRecord::RecordNotFound if @service_inquiry.customer.blank?

      bicycle = @service_inquiry.customer.bicycles.find(params.require(:bicycle_id))
      @service_inquiry.link_bicycle!(bicycle)
      redirect_to admin_service_inquiry_path(@service_inquiry), notice: "자전거를 문의에 연결했습니다."
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      redirect_to admin_service_inquiry_path(@service_inquiry), alert: @service_inquiry.errors.full_messages.to_sentence.presence || "자전거를 연결할 수 없습니다."
    end

    def unlink_linkage
      case params.require(:target)
      when "service_order"
        @service_inquiry.unlink_service_order!
        notice = "서비스오더 연결을 해제했습니다."
      when "bicycle"
        @service_inquiry.unlink_bicycle!
        notice = "자전거 연결을 해제했습니다."
      when "customer"
        @service_inquiry.unlink_customer!
        notice = "고객 연결을 해제했습니다."
      else
        raise ActionController::ParameterMissing, :target
      end

      redirect_to admin_service_inquiry_path(@service_inquiry), notice: notice
    rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing
      redirect_to admin_service_inquiry_path(@service_inquiry), alert: @service_inquiry.errors.full_messages.to_sentence.presence || "연결을 해제할 수 없습니다."
    end

    private

    def set_service_inquiry
      @service_inquiry = ServiceInquiry.includes(:product, :customer, :bicycle, service_order: { bicycle: :customer }).find(params[:id])
    end

    def service_inquiry_params
      params.require(:service_inquiry).permit(:status, :conversion_status, :admin_notes)
    end
  end
end
