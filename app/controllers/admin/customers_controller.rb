module Admin
  class CustomersController < BaseController
    before_action :set_customer, only: %i[show edit update destroy bicycles]
    before_action :set_source_inquiry, only: %i[new create]

    def index
      customers = Customer.search(params[:query]).order(created_at: :desc)
      @pagy, @customers = pagy(customers)
    end

    def show
    end

    def new
      @customer = Customer.new
      @customer.assign_attributes(@source_inquiry.customer_prefill_attributes) if @source_inquiry.present?
    end

    def create
      @customer = Customer.new(customer_params)

      if save_customer_with_optional_inquiry_link
        if @source_inquiry.present?
          redirect_to admin_service_inquiry_path(@source_inquiry), notice: "새 고객을 생성하고 문의에 연결했습니다."
        else
          redirect_to admin_customer_path(@customer), notice: "Customer was successfully created."
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: "Customer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @customer.destroy
      redirect_to admin_customers_path, notice: "Customer was successfully deleted."
    end

    def bicycles
      @bicycles = @customer.bicycles.where(status: :active).order(:brand, :model_label)
      render json: @bicycles.map { |b| { id: b.id, label: "#{b.brand} #{b.model_label} (#{b.year || '-'})" } }
    end

    private

    def set_customer
      @customer = Customer.find(params[:id])
    end

    def set_source_inquiry
      @source_inquiry = ServiceInquiry.find_by(id: params[:service_inquiry_id])
    end

    def save_customer_with_optional_inquiry_link
      ActiveRecord::Base.transaction do
        @customer.save!
        @source_inquiry&.link_customer!(@customer)
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def customer_params
      params.require(:customer).permit(:name, :phone, :email, :kakao_uid, :memo, :active)
    end
  end
end
