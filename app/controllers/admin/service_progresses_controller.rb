module Admin
  class ServiceProgressesController < BaseController
    before_action :set_service_order

    def create
      @service_progress = @service_order.service_progresses.build(service_progress_params)
      @service_progress.from_status = @service_order.status
      @service_progress.to_status = @service_order.status
      @service_progress.entry_type = :manual_update
      @service_progress.customer_visible = true if @service_progress.customer_visible.nil?

      if @service_progress.save
        @service_progress = ServiceProgress.new(review_state: :none)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "고객 업데이트가 추가되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :create, status: :unprocessable_entity }
          format.html do
            render "admin/service_orders/show", status: :unprocessable_entity
          end
        end
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.includes(:service_progresses, :service_photos, :repair_logs, :parts_replacements, bicycle: :customer).find(params[:service_order_id])
    end

    def service_progress_params
      params.require(:service_progress).permit(:title, :note, :work_summary, :cost_summary, :review_state)
    end
  end
end
