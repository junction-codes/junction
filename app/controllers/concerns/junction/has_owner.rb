# frozen_string_literal: true

module Junction
  # Provides helpers for controllers of entities that have an owner.
  module HasOwner
    extend ActiveSupport::Concern

    private

    # Scope for index actions of entities that have an owner.
    #
    # Returns the base relation if the user has access to read all entities.
    # Otherwise, restricts to entities whose owner is in the user's group
    # hierarchy.
    #
    # @param model [Class] ActiveRecord model class.
    # @return [ActiveRecord::Relation] Scoped relation for the index action.
    def index_scope_for(model)
      return model.all if allowed_to?(:index_all?, model)

      model.where(owner_id: current_user.deep_group_ids) if allowed_to?(:index_owned?, model)
    end

    # Group IDs the current user may assign as owner of an entity.
    #
    # @return [Array<Integer>]
    def allowed_owner_ids
      current_user&.deep_group_ids.to_a || []
    end

    # Relation of groups for owner dropdowns.
    #
    # @return [ActiveRecord::Relation]
    def available_owners
      ids = allowed_owner_ids
      scope = Group.select(:description, :id, :image_url, :name).order(:name)
      ids.present? ? scope.where(id: ids) : scope.none
    end

    # Sanitize owner_id input in permitted params.
    #
    # The `owner_id` parameter is only permitted (set) if the user is permitted
    # to assign it to the entity.
    #
    # @param attrs [Hash] Permitted parameters hash.
    # @return [Hash] Sanitized parameters hash.
    def sanitize_owner_id(attrs)
      out = attrs.dup
      return out unless out.key?("owner_id") || out.key?(:owner_id)

      id = (out[:owner_id] || out["owner_id"])
      out[:owner_id] = if id.present?
        (allowed_owner_ids.include?(id.to_i) || id.to_i == entity.owner_id) ? id.to_i : nil
      end

      out["owner_id"] = out[:owner_id] if out.key?("owner_id")
      out
    end
  end
end
