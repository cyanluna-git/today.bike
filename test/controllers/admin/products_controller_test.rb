require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:one)
    @product = products(:chain)
  end

  # --- Authentication tests ---

  test "index requires authentication" do
    get admin_products_path
    assert_redirected_to new_admin_user_session_path
  end

  test "show requires authentication" do
    get admin_product_path(@product)
    assert_redirected_to new_admin_user_session_path
  end

  test "new requires authentication" do
    get new_admin_product_path
    assert_redirected_to new_admin_user_session_path
  end

  test "create requires authentication" do
    post admin_products_path, params: { product: { name: "Test", price: 1000 } }
    assert_redirected_to new_admin_user_session_path
  end

  test "edit requires authentication" do
    get edit_admin_product_path(@product)
    assert_redirected_to new_admin_user_session_path
  end

  test "update requires authentication" do
    patch admin_product_path(@product), params: { product: { name: "Updated" } }
    assert_redirected_to new_admin_user_session_path
  end

  test "destroy requires authentication" do
    delete admin_product_path(@product)
    assert_redirected_to new_admin_user_session_path
  end

  # --- Index ---

  test "index renders successfully" do
    sign_in @admin_user
    get admin_products_path
    assert_response :ok
  end

  test "index page title contains 파츠/용품 관리" do
    sign_in @admin_user
    get admin_products_path
    assert_select "title", text: /파츠\/용품 관리/
  end

  test "index displays products in a table" do
    sign_in @admin_user
    get admin_products_path
    assert_select "table"
    assert_match @product.name, response.body
  end

  test "index has New Product link" do
    sign_in @admin_user
    get admin_products_path
    assert_select "a[href='#{new_admin_product_path}']", text: /New Product/
  end

  test "index shows category badge" do
    sign_in @admin_user
    get admin_products_path
    assert_match @product.category_label, response.body
  end

  test "index shows active status" do
    sign_in @admin_user
    get admin_products_path
    assert_match "Active", response.body
  end

  test "index filters by category" do
    sign_in @admin_user
    get admin_products_path, params: { category: "parts" }
    assert_response :ok
    assert_match @product.name, response.body
  end

  # --- Show ---

  test "show renders successfully" do
    sign_in @admin_user
    get admin_product_path(@product)
    assert_response :ok
  end

  test "show displays product details" do
    sign_in @admin_user
    get admin_product_path(@product)
    assert_match @product.name, response.body
    assert_match @product.category_label, response.body
  end

  test "show has edit and delete actions" do
    sign_in @admin_user
    get admin_product_path(@product)
    assert_select "a[href='#{edit_admin_product_path(@product)}']", text: "Edit"
    assert_select "form[action='#{admin_product_path(@product)}']"
  end

  test "show has back to products link" do
    sign_in @admin_user
    get admin_product_path(@product)
    assert_select "a[href='#{admin_products_path}']", text: /Back to Products/
  end

  # --- New ---

  test "new renders successfully" do
    sign_in @admin_user
    get new_admin_product_path
    assert_response :ok
  end

  test "new renders a form" do
    sign_in @admin_user
    get new_admin_product_path
    assert_select "form"
    assert_select "input[name='product[name]']"
    assert_select "select[name='product[category]']"
  end

  # --- Create ---

  test "create with valid params creates product and redirects" do
    sign_in @admin_user

    assert_difference "Product.count", 1 do
      post admin_products_path, params: {
        product: {
          name: "New Product",
          price: 25000,
          category: "parts"
        }
      }
    end

    product = Product.last
    assert_redirected_to admin_product_path(product)
    follow_redirect!
    assert_match "Product was successfully created", response.body
  end

  test "create with invalid params re-renders new form" do
    sign_in @admin_user

    assert_no_difference "Product.count" do
      post admin_products_path, params: {
        product: { name: "" }
      }
    end

    assert_response :unprocessable_entity
  end

  # --- Edit ---

  test "edit renders successfully" do
    sign_in @admin_user
    get edit_admin_product_path(@product)
    assert_response :ok
  end

  test "edit renders a form with existing values" do
    sign_in @admin_user
    get edit_admin_product_path(@product)
    assert_select "input[name='product[name]'][value='#{@product.name}']"
  end

  # --- Update ---

  test "update with valid params updates product and redirects" do
    sign_in @admin_user

    patch admin_product_path(@product), params: {
      product: { name: "Updated Product" }
    }

    assert_redirected_to admin_product_path(@product)
    follow_redirect!
    assert_match "Product was successfully updated", response.body
    assert_equal "Updated Product", @product.reload.name
  end

  test "update with invalid params re-renders edit form" do
    sign_in @admin_user

    patch admin_product_path(@product), params: {
      product: { name: "" }
    }

    assert_response :unprocessable_entity
  end

  # --- Destroy ---

  test "destroy deletes product and redirects to index" do
    sign_in @admin_user

    assert_difference "Product.count", -1 do
      delete admin_product_path(@product)
    end

    assert_redirected_to admin_products_path
    follow_redirect!
    assert_match "Product was successfully deleted", response.body
  end

  # --- Sidebar ---

  test "sidebar has 파츠/용품 link" do
    sign_in @admin_user
    get admin_products_path
    assert_select "a[href='#{admin_products_path}']", text: /파츠\/용품/
  end
end
