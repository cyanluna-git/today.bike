module Admin
  class BicyclesController < BaseController
    before_action :set_bicycle, only: %i[show edit update destroy]

    def index
      bicycles = Bicycle.includes(:customer).order(created_at: :desc)
      bicycles = bicycles.where(bike_type: params[:bike_type]) if params[:bike_type].present?
      bicycles = bicycles.where(status: params[:status]) if params[:status].present?
      @pagy, @bicycles = pagy(bicycles)
    end

    def show
    end

    def new
      @bicycle = Bicycle.new
      @bicycle.customer_id = params[:customer_id] if params[:customer_id].present?
    end

    def create
      @bicycle = Bicycle.new(bicycle_params)

      if @bicycle.save
        redirect_to admin_bicycle_path(@bicycle), notice: "Bicycle was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @bicycle.update(bicycle_params)
        redirect_to admin_bicycle_path(@bicycle), notice: "Bicycle was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @bicycle.destroy
      redirect_to admin_bicycles_path, notice: "Bicycle was successfully deleted."
    end

    private

    def set_bicycle
      @bicycle = Bicycle.find(params[:id])
    end

    def bicycle_params
      params.require(:bicycle).permit(:brand, :model_label, :year, :frame_number, :bike_type, :color, :status, :customer_id)
    end
  end
end
