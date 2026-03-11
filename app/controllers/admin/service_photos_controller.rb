module Admin
  class ServicePhotosController < BaseController
    before_action :set_service_order

    def create
      @service_photos = []
      photo_type = params[:photo_type] || "before"
      caption = params[:caption]
      files = params[:images]

      if files.blank?
        redirect_to admin_service_order_path(@service_order), alert: "Please select at least one photo."
        return
      end

      Array(files).each do |file|
        photo = @service_order.service_photos.build(
          photo_type: photo_type,
          caption: caption,
          taken_at: Time.current
        )
        photo.image.attach(file)
        @service_photos << photo if photo.save
      end

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order), notice: "#{@service_photos.size} photo(s) uploaded." }
      end
    end

    def destroy
      @service_photo = @service_order.service_photos.find(params[:id])
      @service_photo.destroy

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_order_path(@service_order), notice: "Photo deleted." }
      end
    end

    private

    def set_service_order
      @service_order = ServiceOrder.find(params[:service_order_id])
    end
  end
end
