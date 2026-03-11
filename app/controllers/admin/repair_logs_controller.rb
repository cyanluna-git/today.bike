module Admin
  class RepairLogsController < BaseController
    include ActionView::RecordIdentifier

    before_action :set_service_order
    before_action :set_repair_log, only: %i[edit update destroy]

    def create
      @repair_log = @service_order.repair_logs.build(repair_log_params)

      if @repair_log.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "수리내역이 추가되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("repair_log_form", partial: "admin/repair_logs/form", locals: { service_order: @service_order, repair_log: @repair_log }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @repair_log.errors.full_messages.join(", ") }
        end
      end
    end

    def edit
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order) }
      end
    end

    def update
      if @repair_log.update(repair_log_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "수리내역이 수정되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@repair_log, :form), partial: "admin/repair_logs/form", locals: { service_order: @service_order, repair_log: @repair_log }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @repair_log.errors.full_messages.join(", ") }
        end
      end
    end

    def destroy
      @repair_log.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order), notice: "수리내역이 삭제되었습니다." }
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.find(params[:service_order_id])
    end

    def set_repair_log
      @repair_log = @service_order.repair_logs.find(params[:id])
    end

    def repair_log_params
      params.require(:repair_log).permit(:symptom, :diagnosis, :treatment, :repair_category, :labor_minutes)
    end
  end
end
