# frozen_string_literal: true

module Junction
  class Group < ApplicationRecord
    include Annotated

    attribute :group_type, :string, default: "team"
    alias_attribute :type, :group_type

    validates :description, presence: true
    validates :email, allow_blank: true, format: URI::MailTo::EMAIL_REGEXP
    validates :group_type, presence: true
    validates :image_url, allow_blank: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
    validates :name, presence: true, uniqueness: true

    belongs_to :parent, class_name: "Junction::Group", optional: true
    has_many :children, class_name: "Junction::Group", foreign_key: "parent_id", dependent: :destroy
    has_many :group_memberships, dependent: :destroy, class_name: "Junction::GroupMembership"
    has_many :members, through: :group_memberships, class_name: "Junction::User", source: :user
    has_many :components, foreign_key: "owner_id", class_name: "Junction::Component"
    has_many :systems, foreign_key: "owner_id", class_name: "Junction::System"

    def self.ransackable_associations(auth_object = nil)
      %w[parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description email group_type name parent_id type updated_at]
    end

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
end
