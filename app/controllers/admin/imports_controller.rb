module Admin
  class ImportsController < BaseController
    def new
      @import_type = params[:import_type] || "customers"
    end

    def create
      unless params[:file].present?
        flash.now[:alert] = "파일을 선택해주세요."
        @import_type = params[:import_type] || "customers"
        render :new, status: :unprocessable_entity
        return
      end

      @import_type = params[:import_type] || "customers"
      result = CsvImportService.new(params[:file], @import_type).call

      @result = result
      if result[:errors].any?
        flash.now[:alert] = "가져오기 완료 (일부 오류 발생)"
      else
        flash.now[:notice] = "가져오기가 완료되었습니다."
      end

      render :create
    end
  end
end
