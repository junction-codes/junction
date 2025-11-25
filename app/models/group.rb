# frozen_string_literal: true

class Group < ApplicationRecord
  include Annotated

  attribute :group_type, :string, default: "team"
  alias_attribute :type, :group_type

  validates :description, presence: true
  validates :email, allow_blank: true, format: URI::MailTo::EMAIL_REGEXP
  validates :group_type, presence: true
  validates :name, presence: true, uniqueness: true
  validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  belongs_to :parent, class_name: "Group", optional: true
  has_many :children, class_name: "Group", foreign_key: "parent_id", dependent: :destroy
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, class_name: "User", source: :user
  has_many :components, foreign_key: "owner_id"
  has_many :systems, foreign_key: "owner_id"

  def icon
    CatalogOptions.group_types[type]&.[](:icon) || "users-round"
  end

  def self_and_ancestors
    ancestors = [ self ]
    current = self
    while current.parent
      ancestors << current.parent
      current = current.parent
    end

    ancestors
  end
end
