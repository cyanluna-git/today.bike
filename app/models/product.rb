class Product < ApplicationRecord
  has_many_attached :images

  # Enums
  enum :category, {
    parts: "parts",
    accessories: "accessories",
    apparel: "apparel",
    nutrition: "nutrition",
    other: "other"
  }

  CATEGORY_LABELS = {
    "parts" => "파츠",
    "accessories" => "액세서리",
    "apparel" => "의류",
    "nutrition" => "보급식",
    "other" => "기타"
  }.freeze

  # Validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sale_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: true, allow_blank: true
  validates :category, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { category.present? ? where(category: category) : all }
  scope :in_stock, -> { where("stock_quantity > 0") }
  scope :search, ->(query) {
    return all if query.blank?
    where("name LIKE :q OR brand LIKE :q OR sku LIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

  def category_label
    CATEGORY_LABELS[category] || category&.titleize
  end

  def on_sale?
    sale_price.present? && sale_price < price
  end

  def display_price
    on_sale? ? sale_price : price
  end
end
