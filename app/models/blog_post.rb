class BlogPost < ApplicationRecord
  has_rich_text :content
  has_one_attached :cover_image

  # Enums
  enum :category, {
    maintenance_tips: "maintenance_tips",
    repair_guide: "repair_guide",
    review: "review",
    shop_news: "shop_news",
    other: "other"
  }

  CATEGORY_LABELS = {
    "maintenance_tips" => "정비팁",
    "repair_guide" => "수리가이드",
    "review" => "리뷰",
    "shop_news" => "샵소식",
    "other" => "기타"
  }.freeze

  # Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, presence: true
  validates :source_url, uniqueness: true, allow_blank: true

  # Callbacks
  before_validation :generate_slug, if: -> { title.present? && (slug.blank? || title_changed?) }
  before_save :set_published_at, if: -> { published_changed? && published? }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :by_category, ->(category) { category.present? ? where(category: category) : all }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }

  def category_label
    CATEGORY_LABELS[category] || category&.titleize
  end

  def excerpt(length = 150)
    content.to_plain_text.truncate(length)
  end

  private

  def generate_slug
    base_slug = title.parameterize
    # If parameterize returns empty (e.g., all Korean chars), use a transliteration approach
    base_slug = title.gsub(/[^a-zA-Z0-9가-힣\s-]/, "").gsub(/\s+/, "-").downcase if base_slug.blank?
    # If still blank, use a timestamp-based slug
    base_slug = "post-#{Time.current.to_i}" if base_slug.blank?

    slug_candidate = base_slug
    counter = 2
    while BlogPost.where.not(id: id).exists?(slug: slug_candidate)
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end
    self.slug = slug_candidate
  end

  def set_published_at
    self.published_at ||= Time.current
  end
end
