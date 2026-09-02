# frozen_string_literal: true

module Junction
  class Group < Entity
    include TreeChild
    include TreeParent

    self.catalog_section = :groups
    self.default_icon = "users-round"

    attribute :type, :string, default: "team"

    before_save :sync_role_from_annotation,
                if: -> { annotation_changed?(CorePlugin::ANNOTATION_GROUP_ROLE) }

    validates :description, presence: true
    validates :email, allow_blank: true, format: URI::MailTo::EMAIL_REGEXP
    validates :type, presence: true
    validate :role_is_a_role

    belongs_to :role, class_name: "Junction::Role", optional: true
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

    private

    # Validates that role_id references a role.
    #
    # The association is scoped to Junction::Role, so an id pointing at any
    # other kind resolves to nil. Roles grant permissions, so this guard keeps
    # the column from being pointed anywhere else.
    def role_is_a_role
      return if role_id.blank?

      errors.add(:role_id, :invalid) if role.nil?
    end

    # Syncs the associated role based on the group's annotations.
    #
    # If the role specified in the annotation is not found, the group will not
    # be associated with a role.
    def sync_role_from_annotation
      role_name = annotations.fetch(CorePlugin::ANNOTATION_GROUP_ROLE, nil)
      self.role = role_name.present? ? Role.find_by(name: role_name) : nil
    end
  end
end
