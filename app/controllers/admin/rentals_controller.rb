module Admin
  class RentalsController < BaseController
    before_action :set_rental, only: %i[show edit update destroy]

    def index
      rentals = Rental.order(created_at: :desc)
      rentals = rentals.by_type(params[:rental_type]) if params[:rental_type].present?
      @pagy, @rentals = pagy(rentals)
    end

    def show
    end

    def new
      @rental = Rental.new
    end

    def create
      @rental = Rental.new(rental_params)

      if @rental.save
        redirect_to admin_rental_path(@rental), notice: "Rental was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @rental.update(rental_params)
        redirect_to admin_rental_path(@rental), notice: "Rental was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @rental.destroy
      redirect_to admin_rentals_path, notice: "Rental was successfully deleted."
    end

    private

    def set_rental
      @rental = Rental.find(params[:id])
    end

    def rental_params
      params.require(:rental).permit(:name, :description, :rental_type, :daily_rate, :active, images: [])
    end
  end
end
