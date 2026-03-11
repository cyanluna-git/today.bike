class RepairLog < ApplicationRecord
  # Associations
  belongs_to :service_order

  # Enums
  enum :repair_category, {
    brake: "brake",
    shift: "shift",
    wheel: "wheel",
    bearing: "bearing",
    cable: "cable",
    tire: "tire",
    chain: "chain",
    frame: "frame",
    headset: "headset",
    bottom_bracket: "bottom_bracket",
    pedal: "pedal",
    saddle: "saddle",
    handlebar: "handlebar",
    other: "other"
  }, prefix: :category

  CATEGORY_LABELS = {
    "brake" => "브레이크",
    "shift" => "변속",
    "wheel" => "휠",
    "bearing" => "베어링",
    "cable" => "케이블",
    "tire" => "타이어",
    "chain" => "체인",
    "frame" => "프레임",
    "headset" => "헤드셋",
    "bottom_bracket" => "비비(BB)",
    "pedal" => "페달",
    "saddle" => "안장",
    "handlebar" => "핸들바",
    "other" => "기타"
  }.freeze

  # Validations
  validates :symptom, presence: true
  validates :repair_category, presence: true
  validates :labor_minutes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :ordered, -> { order(created_at: :desc) }

  def category_label
    CATEGORY_LABELS[repair_category] || repair_category&.titleize
  end
end
