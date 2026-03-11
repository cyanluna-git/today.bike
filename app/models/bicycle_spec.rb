class BicycleSpec < ApplicationRecord
  COMPONENTS = %w[
    frame fork wheelset groupset saddle handlebar seatpost tire pedal
    stem bartape chain cassette crankset brakes bottle_cage computer
    powermeter other
  ].freeze

  CATEGORY_GROUPS = {
    frame_fork:      { label: "프레임/포크", icon: "frame", components: %w[frame fork] },
    drivetrain:      { label: "구동계",      icon: "drivetrain", components: %w[groupset crankset cassette chain brakes powermeter] },
    wheels:          { label: "휠셋",        icon: "wheels", components: %w[wheelset tire] },
    contact_points:  { label: "핸들/안장",   icon: "contact", components: %w[handlebar stem saddle seatpost bartape pedal] },
    other:           { label: "기타",        icon: "other", components: %w[bottle_cage computer other] }
  }.freeze

  belongs_to :bicycle

  validates :component, presence: true, inclusion: { in: COMPONENTS }
  validates :brand, presence: true
  validates :component_model, presence: true

  # Returns the category key for this spec's component
  def category
    CATEGORY_GROUPS.each do |key, group|
      return key if group[:components].include?(component)
    end
    :other
  end
end
