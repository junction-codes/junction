# frozen_string_literal: true

module Junction
  # Builds the relations a controller may list, from the current user's
  # permissions.
  module ReadScoped
    extend ActiveSupport::Concern

    private

    # Scope for the index action of a single kind.
    #
    # Returns the base relation if the user may read all entities of the kind.
    # Otherwise restricts to entities owned by the user or by a group in their
    # hierarchy.
    #
    # @param model [Class] ActiveRecord model class.
    # @return [ActiveRecord::Relation, nil] Scoped relation, or nil when the
    #   user may read neither.
    def index_scope_for(model)
      return model.all if allowed_to?(:index_all?, model)

      model.where(owner_id: current_user.owner_ids) if allowed_to?(:index_owned?, model)
    end

    # Scope spanning several kinds, honouring each kind's permissions.
    #
    # Every kind shares a table now, so a cross-kind listing can be one query
    # instead of one per model merged in Ruby. Permissions still differ per
    # kind, so the relation is composed from a per-kind check rather than
    # querying Entity directly, which would also leak users and groups into
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
  end
end
