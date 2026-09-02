# frozen_string_literal: true

module Junction
  # Provides helpers for controllers of entities that have an owner.
  #
  # Read scoping lives in {Junction::ReadScoped}, which this includes, because
  # it applies to kinds without an owner too.
  module HasOwner
    extend ActiveSupport::Concern

    include ReadScoped

    private

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
