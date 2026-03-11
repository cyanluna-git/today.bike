class FrameChange < ApplicationRecord
  # Associations
  belongs_to :service_order

  # Serialization
  serialize :transferred_parts, coder: JSON

  # Callbacks
  after_create :update_bicycle_and_specs

  # Validations
  validates :new_frame_brand, presence: true
  validates :new_frame_model, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :transferred_parts_are_valid_components

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  # Ensure transferred_parts is always an array
  def transferred_parts
    super || []
  end

  private

  def transferred_parts_are_valid_components
    return if transferred_parts.blank?

    invalid = transferred_parts.reject { |p| BicycleSpec::COMPONENTS.include?(p) }
    if invalid.any?
      errors.add(:transferred_parts, "contains invalid components: #{invalid.join(', ')}")
    end
  end

  def update_bicycle_and_specs
    bicycle = service_order.bicycle

    # Update bicycle brand/model from new frame
    bicycle.update!(
      brand: new_frame_brand,
      model_label: new_frame_model
    )

    # Update frame BicycleSpec
    BicycleSpecUpdater.upsert_spec(
      bicycle: bicycle,
      component: "frame",
      brand: new_frame_brand,
      component_model: new_frame_model
    )

    # Destroy BicycleSpec records for components NOT transferred
    kept_components = transferred_parts + [ "frame" ]
    bicycle.bicycle_specs.where.not(component: kept_components).destroy_all
  end
end
