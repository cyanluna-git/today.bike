module Admin
  class FittingRecordsController < BaseController
    before_action :set_bicycle
    before_action :set_fitting_record, only: %i[show edit update destroy]

    def index
      @fitting_records = @bicycle.fitting_records.chronological
      @latest = @fitting_records.first
      @previous = @fitting_records.second
    end

    def show
    end

    def new
      @fitting_record = @bicycle.fitting_records.build
    end

    def create
      @fitting_record = @bicycle.fitting_records.build(fitting_record_params)

      if @fitting_record.save
        redirect_to admin_bicycle_fitting_record_path(@bicycle, @fitting_record), notice: "피팅기록이 추가되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @fitting_record.update(fitting_record_params)
        redirect_to admin_bicycle_fitting_record_path(@bicycle, @fitting_record), notice: "피팅기록이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @fitting_record.destroy
      redirect_to admin_bicycle_fitting_records_path(@bicycle), notice: "피팅기록이 삭제되었습니다."
    end

    private

    def set_bicycle
      @bicycle = Bicycle.find(params[:bicycle_id])
    end

    def set_fitting_record
      @fitting_record = @bicycle.fitting_records.find(params[:id])
    end

    def fitting_record_params
      params.require(:fitting_record).permit(
        :recorded_at, :service_order_id,
        :saddle_height, :saddle_setback, :saddle_tilt, :saddle_brand, :saddle_model,
        :handlebar_width, :handlebar_drop, :handlebar_reach, :handlebar_stack,
        :stem_length, :stem_angle, :stem_spacer,
        :crank_length,
        :cleat_left, :cleat_right,
        :notes,
        photos: []
      )
    end
  end
end
