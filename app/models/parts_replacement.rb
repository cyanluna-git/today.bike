class PartsReplacement < ApplicationRecord
  # Associations
  belongs_to :service_order

  # Callbacks
  after_create :update_bicycle_spec

  # Validations
  validates :component, presence: true, inclusion: { in: BicycleSpec::COMPONENTS }
  validates :new_brand, presence: true
  validates :new_model, presence: true
  validates :cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  COMPONENT_LABELS = {
    "frame" => "프레임",
    "fork" => "포크",
    "wheelset" => "휠셋",
    "groupset" => "구동계",
    "saddle" => "안장",
    "handlebar" => "핸들바",
    "seatpost" => "싯포스트",
    "tire" => "타이어",
    "pedal" => "페달",
    "stem" => "스템",
    "bartape" => "바테이프",
    "chain" => "체인",
    "cassette" => "카세트",
    "crankset" => "크랭크셋",
    "brakes" => "브레이크",
    "bottle_cage" => "물통케이지",
    "computer" => "사이클컴퓨터",
    "powermeter" => "파워미터",
    "other" => "기타"
  }.freeze

  def component_label
    COMPONENT_LABELS[component] || component&.titleize
  end

  private

  def update_bicycle_spec
    BicycleSpecUpdater.upsert_spec(
      bicycle: service_order.bicycle,
      component: component,
      brand: new_brand,
      component_model: new_model
    )
  end
end
