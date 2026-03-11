module Admin
  class FrameChangesController < BaseController
    include ActionView::RecordIdentifier

    before_action :set_service_order
    before_action :set_frame_change, only: %i[edit update destroy]

    def create
      @frame_change = @service_order.frame_changes.build(frame_change_params)

      if @frame_change.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "기변 내역이 추가되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("frame_change_form", partial: "admin/frame_changes/form", locals: { service_order: @service_order, frame_change: @frame_change }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @frame_change.errors.full_messages.join(", ") }
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
      if @frame_change.update(frame_change_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "기변 내역이 수정되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@frame_change, :form), partial: "admin/frame_changes/form", locals: { service_order: @service_order, frame_change: @frame_change }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @frame_change.errors.full_messages.join(", ") }
        end
      end
    end

    def destroy
      @frame_change.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order), notice: "기변 내역이 삭제되었습니다." }
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.find(params[:service_order_id])
    end

    def set_frame_change
      @frame_change = @service_order.frame_changes.find(params[:id])
    end

    def frame_change_params
      params.require(:frame_change).permit(:old_frame_brand, :old_frame_model, :new_frame_brand, :new_frame_model, :new_frame_size, :reason, :cost, transferred_parts: [])
    end
  end
end
