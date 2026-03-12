module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[show edit update destroy]

    def index
      products = Product.search(params[:query]).order(created_at: :desc)
      products = products.by_category(params[:category]) if params[:category].present?
      @pagy, @products = pagy(products)
    end

    def show
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_product_path(@product), notice: "Product was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "Product was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Product was successfully deleted."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :category, :brand, :price, :sale_price, :stock_quantity, :active, :sku, images: [])
    end
  end
end
