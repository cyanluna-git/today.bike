module Portal
  class FittingRecordsController < BaseController
    def index
      @bicycles = current_customer.bicycles
        .includes(:fitting_records)
        .where(fitting_records: { id: FittingRecord.all })
        .or(current_customer.bicycles.includes(:fitting_records))
        .distinct
        .order(created_at: :desc)

      @fitting_records_by_bicycle = current_customer.bicycles
        .includes(fitting_records: { photos_attachments: :blob })
        .each_with_object({}) do |bicycle, hash|
          records = bicycle.fitting_records.chronological
          hash[bicycle] = records if records.any?
        end
    end

    def show
      bicycle_ids = current_customer.bicycles.select(:id)
      @fitting_record = FittingRecord
        .where(bicycle_id: bicycle_ids)
        .find(params[:id])
      @bicycle = @fitting_record.bicycle
    end
  end
end
