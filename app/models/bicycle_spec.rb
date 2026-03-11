class BicycleSpec < ApplicationRecord
  COMPONENTS = %w[
    frame fork wheelset groupset saddle handlebar seatpost tire pedal
    stem bartape chain cassette crankset brakes bottle_cage computer
    powermeter other
  ].freeze

  belongs_to :bicycle

  validates :component, presence: true, inclusion: { in: COMPONENTS }
  validates :brand, presence: true
  validates :component_model, presence: true
end
