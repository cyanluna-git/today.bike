class RentalsController < ApplicationController
  include Pagy::Backend

  def index
    rentals = Rental.active.order(created_at: :desc)
    rentals = rentals.by_type(params[:rental_type]) if params[:rental_type].present?
    @pagy, @rentals = pagy(rentals)
  end

  def show
    @rental = Rental.active.find(params[:id])
    @rental_booking = @rental.rental_bookings.build
    @booked_dates = @rental.booked_dates
  end

  def create_booking
    @rental = Rental.active.find(params[:id])
    @rental_booking = @rental.rental_bookings.build(booking_params)
    @rental_booking.status = :pending

    if @rental_booking.save
      redirect_to booking_confirmation_rental_path(@rental), notice: "예약이 접수되었습니다."
    else
      @booked_dates = @rental.booked_dates
      render :show, status: :unprocessable_entity
    end
  end

  def booking_confirmation
    @rental = Rental.active.find(params[:id])
  end

  private

  def booking_params
    params.require(:rental_booking).permit(:guest_name, :guest_phone, :start_date, :end_date, :notes)
  end
end
