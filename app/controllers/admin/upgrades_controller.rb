module Admin
  class UpgradesController < BaseController
    include ActionView::RecordIdentifier

    before_action :set_service_order
    before_action :set_upgrade, only: %i[edit update destroy]

    def create
      @upgrade = @service_order.upgrades.build(upgrade_params)

      if @upgrade.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "업그레이드 내역이 추가되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("upgrade_form", partial: "admin/upgrades/form", locals: { service_order: @service_order, upgrade: @upgrade }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @upgrade.errors.full_messages.join(", ") }
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
      if @upgrade.update(upgrade_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_service_order_path(@service_order), notice: "업그레이드 내역이 수정되었습니다." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@upgrade, :form), partial: "admin/upgrades/form", locals: { service_order: @service_order, upgrade: @upgrade }) }
          format.html { redirect_to admin_service_order_path(@service_order), alert: @upgrade.errors.full_messages.join(", ") }
        end
      end
    end

    def destroy
      @upgrade.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order), notice: "업그레이드 내역이 삭제되었습니다." }
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.find(params[:service_order_id])
    end

    def set_upgrade
      @upgrade = @service_order.upgrades.find(params[:id])
    end

    def upgrade_params
      params.require(:upgrade).permit(:component, :before_brand, :before_model, :after_brand, :after_model, :upgrade_purpose, :cost)
    end
  end
end
