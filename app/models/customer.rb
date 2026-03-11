class Customer < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :phone, presence: true,
                    uniqueness: true,
                    format: { with: /\A01[016789]-?\d{3,4}-?\d{4}\z/,
                              message: "는 올바른 한국 휴대폰 번호 형식이어야 합니다" }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
                    allow_blank: true
end
