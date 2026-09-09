# frozen_string_literal: true

module Junction
  # Controller access to the relations a user may list.
  #
  # The scoping itself lives in {Junction::ReadableEntities}, so a controller
  # and a component asking the same question get the same answer. This is the
  # controller-shaped access point.
  module ReadScoped
    extend ActiveSupport::Concern

    private

    # Scope for the index action of a single kind.
    #
    # @param model [Class] ActiveRecord model class.
    # @return [ActiveRecord::Relation, nil] Scoped relation, or nil when the
    #   user may read neither.
    def index_scope_for(model)
      readable_entities.scope_for(model)
    end

    # Scope spanning several kinds, honouring each kind's permissions.
    #
    # @param kinds [Array<Junction::Kind>] The kinds to include.
    # @return [ActiveRecord::Relation] The scoped relation.
    def entity_scope_for(kinds)
      readable_entities.scope_across(kinds)
    end

    # Read scoping for the current request.
    #
    # @return [ReadableEntities] Read scoping for the current request.
    def readable_entities
      ReadableEntities.current
    end
  end
end
