class FittingRecord < ApplicationRecord
  # Associations
  belongs_to :bicycle
  belongs_to :service_order, optional: true
  has_many_attached :photos

  # Callbacks
  before_validation :set_recorded_at

  # Validations
  validates :bicycle, presence: true
  validates :saddle_height, presence: true
  validates :recorded_at, presence: true

  # Scopes
  scope :chronological, -> { order(recorded_at: :desc) }

  MEASUREMENT_FIELDS = %i[
    saddle_height saddle_setback saddle_tilt
    handlebar_width handlebar_drop handlebar_reach handlebar_stack
    stem_length stem_angle stem_spacer
    crank_length
  ].freeze

  TEXT_FIELDS = %i[
    saddle_brand saddle_model
    cleat_left cleat_right
    notes
  ].freeze

  # Returns a hash of changed fields with deltas compared to another record.
  # Example: { saddle_height: { from: 720.0, to: 722.0, delta: 2.0 }, ... }
  def diff_from(other)
    return {} unless other.is_a?(FittingRecord)

    changes = {}

    MEASUREMENT_FIELDS.each do |field|
      current_val = send(field)
      other_val = other.send(field)
      next if current_val == other_val
      next if current_val.nil? && other_val.nil?

      delta = if current_val.present? && other_val.present?
        current_val - other_val
      end

      changes[field] = { from: other_val, to: current_val, delta: delta }
    end

    TEXT_FIELDS.each do |field|
      current_val = send(field)
      other_val = other.send(field)
      next if current_val == other_val

      changes[field] = { from: other_val, to: current_val }
    end

    changes
  end

  private

  def set_recorded_at
    self.recorded_at ||= Time.current
  end
end
