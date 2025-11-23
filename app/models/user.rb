# frozen_string_literal: true

class User < ApplicationRecord
  include Annotated

  has_secure_password

  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, password: true, if: :password_being_set?
  validates :display_name, presence: true
  validates :email_address, presence: true, format: URI::MailTo::EMAIL_REGEXP, uniqueness: true, confirmation: { if: :will_save_change_to_email_address? }
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  has_many :sessions, dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def password_being_set?
    password.present?
  end

  def components
    Component.where(owner: deep_group_ids).uniq
  end

  def systems
    System.where(owner: deep_group_ids).uniq
  end

  # IDs of all groups this user is a member of, and all of their ancestors.
  def deep_group_ids
    group_memberships.includes(group: :parent)
                     .map(&:group).flat_map(&:self_and_ancestors).uniq
  end
end
