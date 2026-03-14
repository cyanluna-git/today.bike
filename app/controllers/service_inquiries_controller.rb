class ServiceInquiriesController < ApplicationController
  def new
    @service_inquiry = ServiceInquiry.new(inquiry_context_params)
  end

  def create
    @service_inquiry = ServiceInquiry.new(service_inquiry_params)

    if @service_inquiry.save
      redirect_to confirmation_service_inquiries_path, notice: "문의가 접수되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
  end

  private

  def inquiry_context_params
    params.permit(:service_type, :product_id, :source_page)
  end

  def service_inquiry_params
    params.require(:service_inquiry).permit(
      :name, :phone, :email, :message, :desired_visit_on, :service_type, :product_id, :source_page
    )
  end
end
