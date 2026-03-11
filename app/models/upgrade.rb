class Upgrade < ApplicationRecord
  # Associations
  belongs_to :service_order

  # Callbacks
  after_create :update_bicycle_spec

  # Enums
  enum :upgrade_purpose, {
    lightweight: "lightweight",
    performance: "performance",
    aero: "aero",
    comfort: "comfort",
    other: "other"
  }

  PURPOSE_LABELS = {
    "lightweight" => "경량화",
    "performance" => "성능향상",
    "aero" => "에어로",
    "comfort" => "편안함",
    "other" => "기타"
  }.freeze

  COMPONENT_LABELS = PartsReplacement::COMPONENT_LABELS

  # Validations
  validates :component, presence: true, inclusion: { in: BicycleSpec::COMPONENTS }
  validates :after_brand, presence: true
  validates :after_model, presence: true
  validates :upgrade_purpose, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  def component_label
    COMPONENT_LABELS[component] || component&.titleize
  end

  def purpose_label
    PURPOSE_LABELS[upgrade_purpose] || upgrade_purpose&.titleize
  end

  private

  def update_bicycle_spec
    BicycleSpecUpdater.upsert_spec(
      bicycle: service_order.bicycle,
      component: component,
      brand: after_brand,
      component_model: after_model
    )
  end
end
