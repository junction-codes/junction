# frozen_string_literal: true

module Junction
  class Group < Entity
    include TreeChild
    include TreeParent

    self.catalog_section = :groups
    self.default_icon = "users-round"

    attribute :type, :string, default: "team"

    validates :description, presence: true
    validates :email, allow_blank: true, format: URI::MailTo::EMAIL_REGEXP
    validates :type, presence: true

    has_many :group_roles, dependent: :destroy, class_name: "Junction::GroupRole"
    has_many :roles, through: :group_roles, class_name: "Junction::Role"
    has_many :group_memberships, dependent: :destroy,
             class_name: "Junction::GroupMembership"
    has_many :members, through: :group_memberships,
             class_name: "Junction::User", source: :user
    has_many :components, foreign_key: "owner_id", class_name: "Junction::Component"
    has_many :systems, foreign_key: "owner_id", class_name: "Junction::System"

    def self.ransackable_associations(auth_object = nil)
      %w[parent children]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[created_at description email name parent_id title type updated_at]
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
