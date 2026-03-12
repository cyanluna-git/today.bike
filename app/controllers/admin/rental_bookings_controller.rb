module Admin
  class RentalBookingsController < BaseController
    before_action :set_rental
    before_action :set_rental_booking, only: %i[show edit update destroy]

    def index
      bookings = @rental.rental_bookings.order(created_at: :desc)
      bookings = bookings.where(status: params[:status]) if params[:status].present?
      @pagy, @rental_bookings = pagy(bookings)
    end

    def show
    end

    def new
      @rental_booking = @rental.rental_bookings.build
    end

    def create
      @rental_booking = @rental.rental_bookings.build(rental_booking_params)

      if @rental_booking.save
        redirect_to admin_rental_rental_booking_path(@rental, @rental_booking), notice: "Booking was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @rental_booking.update(rental_booking_params)
        redirect_to admin_rental_rental_booking_path(@rental, @rental_booking), notice: "Booking was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @rental_booking.destroy
      redirect_to admin_rental_rental_bookings_path(@rental), notice: "Booking was successfully deleted."
    end

    private

    def set_rental
      @rental = Rental.find(params[:rental_id])
    end

    def set_rental_booking
      @rental_booking = @rental.rental_bookings.find(params[:id])
    end

    def rental_booking_params
      params.require(:rental_booking).permit(:customer_id, :guest_name, :guest_phone, :start_date, :end_date, :status, :total_amount, :notes)
    end
  end
end
