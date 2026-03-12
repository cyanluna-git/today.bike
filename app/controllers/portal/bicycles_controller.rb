module Portal
  class BicyclesController < BaseController
    def index
      @bicycles = current_customer.bicycles.order(created_at: :desc)
    end

    def show
      @bicycle = current_customer.bicycles.includes(:bicycle_specs).find(params[:id])
      @grouped_specs = @bicycle.grouped_specs
    end
  end
end
