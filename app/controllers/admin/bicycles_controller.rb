module Admin
  class BicyclesController < BaseController
    before_action :set_bicycle, only: %i[show edit update destroy purge_photo qr_code qr_print]

    def index
      bicycles = Bicycle.includes(:customer).search(params[:query]).order(created_at: :desc)
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

    def qr_code
      @bicycle.ensure_passport_token!
      svg = QrCodeService.generate_svg(@bicycle.passport_url)

      respond_to do |format|
        format.svg { render inline: svg, content_type: "image/svg+xml" }
        format.png do
          png = QrCodeService.generate_png(@bicycle.passport_url)
          send_data png.to_s, type: "image/png", disposition: "attachment",
                    filename: "qr_#{@bicycle.brand}_#{@bicycle.model_label}.png"
        end
        format.html { render inline: svg, content_type: "image/svg+xml" }
      end
    end

    def qr_print
      @bicycle.ensure_passport_token!
      @qr_svg = QrCodeService.generate_svg(@bicycle.passport_url, size: 6)
      render layout: false
    end

    def purge_photo
      @photo = @bicycle.photos.find(params[:photo_id])
      @photo.purge

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("photo_#{params[:photo_id]}") }
        format.html { redirect_to admin_bicycle_path(@bicycle), notice: "Photo was successfully deleted." }
      end
    end

    private

    def set_bicycle
      @bicycle = Bicycle.includes(:bicycle_specs).find(params[:id])
    end

    def bicycle_params
      params.require(:bicycle).permit(:brand, :model_label, :year, :frame_number, :bike_type, :color, :status, :customer_id, photos: [])
    end
  end
end
