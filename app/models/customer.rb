class Customer < ApplicationRecord
  # Associations
  has_many :bicycles, dependent: :destroy
  has_many :service_orders, through: :bicycles

  # Scopes
  scope :search, ->(query) {
    return all if query.blank?
    where("name LIKE :q OR phone LIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

  # Validations
  validates :name, presence: true
  validates :phone, presence: true,
                    uniqueness: true,
                    format: { with: /\A01[016789]-?\d{3,4}-?\d{4}\z/,
                              message: "는 올바른 한국 휴대폰 번호 형식이어야 합니다" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
                    allow_blank: true

  # Find customer by Kakao UID or phone number for portal login matching
  def self.find_for_kakao_auth(kakao_uid:, phone: nil)
    # First try to find by kakao_uid
    customer = find_by(kakao_uid: kakao_uid) if kakao_uid.present?
    return customer if customer

    # Fall back to phone number matching
    if phone.present?
      customer = find_by(phone: phone)
      if customer
        customer.update!(kakao_uid: kakao_uid) if kakao_uid.present?
        return customer
      end
    end

    nil
  end
end
