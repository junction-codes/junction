# frozen_string_literal: true

module Junction
  # Represents a role used for authorization.
  #
  # Roles are catalog entities so they can be declared in YAML and imported
  # alongside everything else. The `system` flag lives in `spec` rather than in
  # a column: every entity row now has a `system` association, which a `system`
  # attribute would be ambiguous with.
  class Role < Entity
    self.default_icon = "shield-check"

    store_accessor :spec, :system_role

    validates :description, presence: true

    has_many :groups, foreign_key: "role_id", class_name: "Junction::Group"
    has_many :role_permissions, dependent: :destroy,
             class_name: "Junction::RolePermission"

    before_destroy :prevent_system_role_deletion

    def self.ransackable_associations(auth_object = nil)
      %w[role_permissions]
    end

    def self.ransackable_attributes(auth_object = nil)
      %w[description name title]
    end

    # String representation of the permissions assigned to this role.
    #
    # @return [Array<String>] List of permission strings assigned to this role.
    #
    # @todo Include system-role expansion.
    def permission_strings
      role_permissions.order(:permission).pluck(:permission)
    end

    # Whether this role is a system role.
    #
    # @return [Boolean] True if the role is a system role, false otherwise.
    def system?
      ActiveModel::Type::Boolean.new.cast(system_role) == true
    end

    private

    # Prevents the deletion of system roles.
    #
    # @raise [ActiveRecord::RecordNotDestroyed] If the role is a system role.
    def prevent_system_role_deletion
      throw(:abort) if system?
    end
  end
end
