# frozen_string_literal: true

module Junction
  # Controller for managing Groups.
  class GroupsController < ApplicationController
    # Declared before Breadcrumbs so the entity is set before any breadcrumb
    # helper runs.
    include CatalogEntityActions

    include Breadcrumbs
    include CatalogOptionSets
    include HasAnnotations
    include HasTreeParent
    include Paginatable

    PARENT_CANDIDATE_COLUMNS = %i[description id image_url name namespace title].freeze
    private_constant :PARENT_CANDIDATE_COLUMNS

    private

    def entity_class
      Group
    end

    def index_options
      { available_types: }
    end

    def show_options(_entity)
      { can_view_members: allowed_to?(:index_all?, User) }
    end

    def form_options(entity)
      {
        available_parents:,
        parent_editable: parent_editable_for?(entity),
        type_options:,
        available_roles: (Role.order(:title) if can_manage_roles?)
      }
    end

    # Whether the current user may grant roles.
    #
    # Granting a role is a privilege change, so it is gated on role write
    # access rather than on the ability to edit the group.
    #
    # @return [Boolean]
    def can_manage_roles?
      allowed_to?(:update?, Role)
    end

    def create_params
      attrs = sanitize_annotations(params.expect(group: [
        :description, :email, :image_url, :name, :namespace,
        :parent_id, :title, :type, *annotation_param_entries
      ]))

      attrs = sanitize_tree_parent_id(attrs, parent_candidates: available_parents)
      attrs[:role_ids] = permitted_role_ids if can_manage_roles?
      attrs
    end

    # Role IDs the request asked to grant, ignoring blanks.
    #
    # @return [Array<Integer>] The role IDs.
    def permitted_role_ids
      params.fetch(:group, {}).fetch(:role_ids, []).reject(&:blank?).map(&:to_i)
    end

    # Returns the available parents for the current Group and user.
    #
    # @return [ActiveRecord::Relation<Group>] List of parent candidates.
    def available_parents
      parent_candidates_for(
        Group,
        scope: index_scope_for(Group),
        columns: PARENT_CANDIDATE_COLUMNS
      )
    end
  end
end
