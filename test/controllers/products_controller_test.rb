require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:chain)
    @inactive_product = products(:inactive_product)
  end

  # --- Index ---

  test "index renders successfully" do
    get products_path
    assert_response :ok
  end

  test "index page title contains Products" do
    get products_path
    assert_select "title", text: /Products/
  end

  test "index shows active products" do
    get products_path
    assert_match @product.name, response.body
  end

  test "index does not show inactive products" do
    get products_path
    assert_no_match @inactive_product.name, response.body
  end

  test "index shows category badges" do
    get products_path
    assert_match @product.category_label, response.body
  end

  test "index filters by category" do
    get products_path, params: { category: "parts" }
    assert_response :ok
    assert_match @product.name, response.body
  end

  test "index category filter excludes other categories" do
    get products_path, params: { category: "apparel" }
    assert_response :ok
    assert_no_match @product.name, response.body
  end

  test "index has category filter tabs" do
    get products_path
    assert_select "nav[aria-label='Category filter']"
    assert_select "a", text: "All"
  end

  test "index shows sale price when on sale" do
    tire = products(:tire)
    get products_path
    assert_match tire.name, response.body
  end

  # --- Show ---

  test "show renders successfully for active product" do
    get product_path(@product)
    assert_response :ok
  end

  test "show displays product name" do
    get product_path(@product)
    assert_match @product.name, response.body
  end

  test "show displays category badge" do
    get product_path(@product)
    assert_match @product.category_label, response.body
  end

  test "show displays price" do
    get product_path(@product)
    assert_match "35,000", response.body
  end

  test "show has internal inquiry button" do
    get product_path(@product)
    assert_select "a[href='#{new_service_inquiry_path(product_id: @product.id, source_page: "product")}']", text: /문의 접수하기/
  end

  test "show has back to products link" do
    get product_path(@product)
    assert_select "a[href='#{products_path}']", text: /Back to Products/
  end

  test "show returns 404 for inactive product" do
    get product_path(@inactive_product)
    assert_response :not_found
  end

  test "show displays sale price with strikethrough when on sale" do
    tire = products(:tire)
    get product_path(tire)
    assert_select "span.line-through"
    assert_match "55,000", response.body
  end
end
