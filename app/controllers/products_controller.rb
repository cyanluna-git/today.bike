class ProductsController < ApplicationController
  include Pagy::Backend

  def index
    products = Product.active.order(created_at: :desc)
    products = products.by_category(params[:category]) if params[:category].present?
    products = products.search(params[:query]) if params[:query].present?
    @pagy, @products = pagy(products)
  end

  def show
    @product = Product.active.find(params[:id])
  end
end
