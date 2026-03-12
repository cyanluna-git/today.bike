class PassportsController < ApplicationController
  layout "passport"

  def show
    @bicycle = Bicycle.includes(:customer, :bicycle_specs, :fitting_records, :service_orders)
                       .find_by(passport_token: params[:token])

    if @bicycle.nil?
      render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
    end
  end
end
