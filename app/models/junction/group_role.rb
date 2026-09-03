# frozen_string_literal: true

module Junction
  # Grants a role to a group.
  #
  # A dedicated table rather than a row in `junction_relations`: a role grant is
  # a privilege change, so it is gated by its own permission instead of by
  # catalog write access.
  class GroupRole < ApplicationRecord
    belongs_to :group, class_name: "Junction::Group", inverse_of: :group_roles
    belongs_to :role, class_name: "Junction::Role", inverse_of: :group_roles

    validates :group_id, uniqueness: { scope: :role_id }

    def self.ransackable_attributes(_auth_object = nil)
      %w[created_at group_id role_id updated_at]
    end

    def self.ransackable_associations(_auth_object = nil)
      %w[group role]
    end
  end
end
