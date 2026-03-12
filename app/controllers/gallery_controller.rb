class GalleryController < ApplicationController
  include Pagy::Backend

  def index
    # Find service orders that have both before AND after photos and are marked as showcase
    showcase_orders = ServiceOrder
      .where(showcase: true)
      .joins(:service_photos)
      .where(service_photos: { photo_type: "before" })
      .where(id: ServiceOrder.joins(:service_photos).where(service_photos: { photo_type: "after" }))
      .distinct
      .includes(:bicycle, :customer)
      .order(completed_at: :desc, created_at: :desc)

    @pagy, @service_orders = pagy(showcase_orders)
  end
end
