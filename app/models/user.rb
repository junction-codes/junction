class User < ApplicationRecord
  has_secure_password

  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, password: true, if: :password_being_set?
  validates :display_name, presence: true
  validates :email_address, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true, confirmation: { if: :will_save_change_to_email_address? }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def password_being_set?
    password.present?
  end
end
