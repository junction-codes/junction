# frozen_string_literal: true

module Junction
  # Controller helpers for assigning a parent within a tree hierarchy.
  module HasTreeParent
    extend ActiveSupport::Concern

    private

    # Candidate parents for +entity+, excluding itself and its descendants.
    #
    # @param model [Class] Entity model class.
    # @param entity [ApplicationRecord] Entity with parent relationship.
    # @param scope [ActiveRecord::Relation] Readable scope for parent picks.
    # @param columns [Array<Symbol>] Columns to select for parent pickers.
    # @return [ActiveRecord::Relation]
    def parent_candidates_for(model, entity: @entity, scope:, columns:)
      return model.none unless scope

      scope = scope.select(*columns).order(:title)
      return scope unless entity&.persisted?

      scope.where.not(id: [ entity.id, *entity.descendant_ids ])
    end

    # Whether the user may change an entity's parent assignment.
    #
    # @param entity [ApplicationRecord] Entity with parent relationship.
    # @return [Boolean]
    def parent_editable_for?(entity = @entity)
      entity.parent.blank? || allowed_to?(:show?, entity.parent)
    end

    # Sanitizes a permitted +parent_id+ in +attrs+ against based on the entity's
    # allowed parent candidates.
    #
    # @param attrs [Hash] Permitted parameters hash.
    # @param entity [ApplicationRecord] Entity with parent relationship.
    # @param parent_candidates [ActiveRecord::Relation] Allowed parent
    #   candidates.
    # @return [Hash] Sanitized parameters hash.
    def sanitize_tree_parent_id(attrs, entity: @entity, parent_candidates:)
      out = attrs.dup
      return out unless out.key?("parent_id") || out.key?(:parent_id)

      id = out[:parent_id] || out["parent_id"]

      if entity&.persisted? && !parent_editable_for?(entity)
        out[:parent_id] = entity.parent_id
        out["parent_id"] = out[:parent_id] if out.key?("parent_id")
        return out
      end

      out[:parent_id] = if id.blank?
        nil
      elsif parent_id_allowed_for?(id.to_i, entity:, parent_candidates:)
        id.to_i
      end

      out["parent_id"] = out[:parent_id] if out.key?("parent_id")
      out
    end

    # Determines if a parent id is an allowed value for an entity.
    #
    # @param parent_id [Integer] ID of the parent to check.
    # @param entity [ApplicationRecord] Entity with parent relationship.
    # @param parent_candidates [ActiveRecord::Relation] Allowed parent
    #   candidates.
    # @return [Boolean] Whether the parent is allowed.
    def parent_id_allowed_for?(parent_id, entity:, parent_candidates:)
      return true if parent_id == entity&.parent_id

      parent_candidates.where(id: parent_id).exists?
    end
  end
end
