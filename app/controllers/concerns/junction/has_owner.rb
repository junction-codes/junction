# frozen_string_literal: true

module Junction
  # Provides helpers for controllers of entities that have an owner.
  module HasOwner
    extend ActiveSupport::Concern

    include ReadScoped

    private

    # Whether the current user may name any group or user as an owner.
    #
    # Write access to every entity of the kind already allows editing all of
    # them, so restricting who may be named as their owner protects nothing.
    # Without it the user is held to owners they are part of, which stops them
    # handing an entity to someone else or claiming one for a group they do
    # not belong to.
    #
    # @return [Boolean]
    def assign_any_owner?
      allowed_to?(:create_all?, entity_class)
    end

    # Entity IDs the current user may assign as owner, when they are held to
    # their own groups.
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
      scope = Entity.where(kind: Ownable::OWNER_KINDS)
                    .select(:description, :id, :image_url, :title)
                    .order(:title)
      return scope if assign_any_owner?

      ids = allowed_owner_ids
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
      out[:owner_id] = (id.to_i if id.present? && permitted_owner_id?(id.to_i))

      out["owner_id"] = out[:owner_id] if out.key?("owner_id")
      out
    end

    # Whether the current user may assign the given owner.
    #
    # Only authorization is decided here. Whether the id names something that
    # may own an entity at all is left to {Junction::Ownable}, so a bad id
    # fails validation rather than being silently dropped.
    #
    # @param id [Integer] The proposed owner's ID.
    # @return [Boolean]
    def permitted_owner_id?(id)
      return true if assign_any_owner?

      allowed_owner_ids.include?(id) || id == @entity&.owner_id
    end
  end
end
