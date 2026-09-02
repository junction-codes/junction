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

      model.where(owner_id: current_user.owner_ids) if allowed_to?(:index_owned?, model)
    end

    # Scope spanning several kinds, honouring each kind's permissions.
    #
    # Every kind shares a table now, so a cross-kind listing can be one query
    # instead of one per model merged in Ruby. Permissions still differ per
    # kind, so the relation is composed from a per-kind check rather than
    # querying Entity directly -- which would also leak users and groups into
    # catalog listings.
    #
    # @param kinds [Array<Junction::Kind>] The kinds to include.
    # @return [ActiveRecord::Relation] The scoped relation.
    def entity_scope_for(kinds)
      scopes = kinds.filter_map do |kind|
        model = kind.model
        next Entity.where(kind: kind.name) if allowed_to?(:index_all?, model)

        if allowed_to?(:index_owned?, model)
          Entity.where(kind: kind.name, owner_id: current_user.owner_ids)
        end
      end

      scopes.reduce(:or) || Entity.none
    end

    # Entity IDs the current user may assign as owner of an entity.
    #
    # An entity may be owned by a group the user belongs to, or by the user
    # themselves.
    #
    # @return [Array<Integer>]
    def allowed_owner_ids
      current_user&.owner_ids || []
    end

    # Relation of entities for owner dropdowns.
    #
    # @return [ActiveRecord::Relation]
    def available_owners
      ids = allowed_owner_ids
      scope = Entity.where(kind: Ownable::OWNER_KINDS)
                    .select(:description, :id, :image_url, :title)
                    .order(:title)
      ids.present? ? scope.where(id: ids) : scope.none
    end

    # Sanitize owner_id input in permitted params.
    #
    # The `owner_id` parameter is only permitted (set) if the user is permitted
    # to assign it to the entity. An entity may keep the owner it already has,
    # even when that group is outside the user's hierarchy. On create there is
    # no entity yet, so only the user's own groups are allowed.
    #
    # @param attrs [Hash] Permitted parameters hash.
    # @return [Hash] Sanitized parameters hash.
    def sanitize_owner_id(attrs)
      out = attrs.dup
      return out unless out.key?("owner_id") || out.key?(:owner_id)

      id = (out[:owner_id] || out["owner_id"])
      out[:owner_id] = if id.present?
        (allowed_owner_ids.include?(id.to_i) || id.to_i == @entity&.owner_id) ? id.to_i : nil
      end

      out["owner_id"] = out[:owner_id] if out.key?("owner_id")
      out
    end
  end
end
