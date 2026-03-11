module Admin
  class BicycleSpecsController < BaseController
    before_action :set_bicycle
    before_action :set_bicycle_spec, only: %i[edit update destroy]

    def new
      @bicycle_spec = @bicycle.bicycle_specs.build

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_bicycle_path(@bicycle) }
      end
    end

    def create
      @bicycle_spec = @bicycle.bicycle_specs.build(bicycle_spec_params)

      if @bicycle_spec.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_bicycle_path(@bicycle), notice: "Spec was successfully added." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :new, status: :unprocessable_entity }
          format.html { redirect_to admin_bicycle_path(@bicycle), alert: "Failed to add spec." }
        end
      end
    end

    def edit
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_bicycle_path(@bicycle) }
      end
    end

    def update
      if @bicycle_spec.update(bicycle_spec_params)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_bicycle_path(@bicycle), notice: "Spec was successfully updated." }
        end
      else
        respond_to do |format|
          format.turbo_stream { render :edit, status: :unprocessable_entity }
          format.html { redirect_to admin_bicycle_path(@bicycle), alert: "Failed to update spec." }
        end
      end
    end

    def destroy
      @bicycle_spec.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_bicycle_path(@bicycle), notice: "Spec was successfully deleted." }
      end
    end

    private

    def set_bicycle
      @bicycle = Bicycle.find(params[:bicycle_id])
    end

    def set_bicycle_spec
      @bicycle_spec = @bicycle.bicycle_specs.find(params[:id])
    end

    def bicycle_spec_params
      params.require(:bicycle_spec).permit(:component, :brand, :component_model, :spec_detail)
    end
  end
end
