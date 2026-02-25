# frozen_string_literal: true

module Junction
  # Provides helpers for controllers of entities that have an owner.
  module HasOwner
    extend ActiveSupport::Concern

    private

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

      id = (out[:owner_id] || out["owner_id"])&.to_i
      out[:owner_id] = (id.present? && allowed_owner_ids.include?(id)) ? id : nil
      out["owner_id"] = out[:owner_id] if out.key?("owner_id")
      out
    end
  end
end
