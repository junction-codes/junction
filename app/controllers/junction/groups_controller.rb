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
        type_options:
      }
    end

    def create_params
      attrs = sanitize_annotations(params.expect(group: [
        :description, :email, :image_url, :name, :namespace,
        :parent_id, :title, :type, *annotation_param_entries
      ]))

      sanitize_tree_parent_id(attrs, parent_candidates: available_parents)
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
