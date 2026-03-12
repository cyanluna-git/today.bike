require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @product = Product.new(
      name: "Test Product",
      price: 50000,
      category: "parts"
    )
  end

  # --- Valid record ---

  test "valid product with all required fields" do
    assert @product.valid?
  end

  test "valid product with all fields" do
    @product.assign_attributes(
      description: "A great product",
      brand: "Shimano",
      sale_price: 40000,
      stock_quantity: 10,
      sku: "TST-001"
    )
    assert @product.valid?
  end

  # --- Name validation ---

  test "invalid without name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  # --- Price validation ---

  test "invalid without price" do
    @product.price = nil
    assert_not @product.valid?
    assert_includes @product.errors[:price], "can't be blank"
  end

  test "price must be non-negative" do
    @product.price = -1
    assert_not @product.valid?
  end

  test "price zero is valid" do
    @product.price = 0
    assert @product.valid?
  end

  # --- Sale price ---

  test "sale_price is optional" do
    @product.sale_price = nil
    assert @product.valid?
  end

  test "sale_price must be non-negative when present" do
    @product.sale_price = -1
    assert_not @product.valid?
  end

  # --- SKU uniqueness ---

  test "sku must be unique" do
    @product.sku = "UNIQUE-SKU"
    @product.save!
    another = Product.new(name: "Another", price: 10000, sku: "UNIQUE-SKU")
    assert_not another.valid?
    assert_includes another.errors[:sku], "has already been taken"
  end

  test "sku allows blank" do
    @product.sku = ""
    assert @product.valid?
  end

  # --- Category enum ---

  test "category parts" do
    @product.category = "parts"
    assert @product.parts?
  end

  test "category accessories" do
    @product.category = "accessories"
    assert @product.accessories?
  end

  test "category apparel" do
    @product.category = "apparel"
    assert @product.apparel?
  end

  test "category nutrition" do
    @product.category = "nutrition"
    assert @product.nutrition?
  end

  test "category other" do
    @product.category = "other"
    assert @product.other?
  end

  test "invalid category raises ArgumentError" do
    assert_raises(ArgumentError) do
      @product.category = "invalid_category"
    end
  end

  # --- Category labels ---

  test "category_label returns Korean label" do
    @product.category = "parts"
    assert_equal "파츠", @product.category_label
  end

  test "category_label for accessories" do
    @product.category = "accessories"
    assert_equal "액세서리", @product.category_label
  end

  # --- Defaults ---

  test "default active is true" do
    product = Product.new(name: "Test", price: 100)
    assert_equal true, product.active
  end

  test "default stock_quantity is 0" do
    product = Product.new(name: "Test", price: 100)
    assert_equal 0, product.stock_quantity
  end

  test "default category is other" do
    product = Product.new(name: "Test", price: 100)
    assert_equal "other", product.category
  end

  # --- on_sale? ---

  test "on_sale? returns true when sale_price is less than price" do
    @product.sale_price = 40000
    assert @product.on_sale?
  end

  test "on_sale? returns false when no sale_price" do
    @product.sale_price = nil
    assert_not @product.on_sale?
  end

  test "on_sale? returns false when sale_price equals price" do
    @product.sale_price = @product.price
    assert_not @product.on_sale?
  end

  # --- display_price ---

  test "display_price returns sale_price when on sale" do
    @product.sale_price = 40000
    assert_equal 40000, @product.display_price
  end

  test "display_price returns price when not on sale" do
    @product.sale_price = nil
    assert_equal 50000, @product.display_price
  end

  # --- Scopes ---

  test "active scope returns only active products" do
    active_products = Product.active
    assert active_products.all?(&:active?)
  end

  test "by_category scope filters by category" do
    parts = Product.by_category("parts")
    assert parts.all? { |p| p.category == "parts" }
  end

  test "by_category scope returns all when blank" do
    assert_equal Product.count, Product.by_category(nil).count
  end

  test "in_stock scope returns products with stock > 0" do
    in_stock = Product.in_stock
    assert in_stock.all? { |p| p.stock_quantity > 0 }
  end

  test "search scope finds by name" do
    results = Product.search("Shimano")
    assert results.any?
    assert results.all? { |p| p.name.include?("Shimano") || p.brand&.include?("Shimano") || p.sku&.include?("Shimano") }
  end

  test "search scope returns all when blank" do
    assert_equal Product.count, Product.search(nil).count
    assert_equal Product.count, Product.search("").count
  end

  # --- Fixtures ---

  test "fixtures are loaded" do
    chain = products(:chain)
    assert_equal "Shimano CN-HG701", chain.name
    assert_equal "parts", chain.category
    assert chain.active?
    assert_equal 35000, chain.price

    tire = products(:tire)
    assert tire.on_sale?
    assert_equal 55000, tire.sale_price

    inactive = products(:inactive_product)
    assert_not inactive.active?
  end
end
