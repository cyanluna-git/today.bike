module Admin
  class PartsReplacementsController < BaseController
    include ActionView::RecordIdentifier

    before_action :set_service_order
    before_action :set_parts_replacement, only: %i[edit update destroy]

    def create
      @parts_replacement = @service_order.parts_replacements.build(parts_replacement_params)

      if @parts_replacement.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "부품교체 내역이 추가되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("parts_replacement_form", partial: "admin/parts_replacements/form", locals: { service_order: @service_order, parts_replacement: @parts_replacement }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @parts_replacement.errors.full_messages.join(", ") }
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
      if @parts_replacement.update(parts_replacement_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "부품교체 내역이 수정되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@parts_replacement, :form), partial: "admin/parts_replacements/form", locals: { service_order: @service_order, parts_replacement: @parts_replacement }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @parts_replacement.errors.full_messages.join(", ") }
        end
      end
    end

    def destroy
      @parts_replacement.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order), notice: "부품교체 내역이 삭제되었습니다." }
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.find(params[:service_order_id])
    end

    def set_parts_replacement
      @parts_replacement = @service_order.parts_replacements.find(params[:id])
    end

    def parts_replacement_params
      params.require(:parts_replacement).permit(:component, :old_brand, :old_model, :new_brand, :new_model, :reason, :cost)
    end
  end
end
