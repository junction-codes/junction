# frozen_string_literal: true

module Junction
  # Policy for every catalog entity.
  #
  # All kinds share one policy because they share one authorization model. Only
  # the permission context differs, and that is derived from the kind registry
  # rather than restated in a policy class per kind.
  #
  # {Junction::Entity.policy_class} points every kind here, so a kind can never
  # silently fall through to a policy carrying the wrong context.
  class EntityPolicy < Junction::ApplicationPolicy
    # Permission domain for the record under authorization.
    #
    # Taken from the kind, so a kind a plugin registers resolves against that
    # plugin's domain rather than the core one.
    #
    # @return [String] The domain.
    def domain
      kind.domain
    end

    # Permission context for the record under authorization.
    #
    # @return [String] The context.
    def context
      kind.context
    end

    private

    # Registered kind for the record under authorization.
    #
    # @return [Junction::Kind] The kind.
    #
    # @raise [ArgumentError] If the record's kind is not registered.
    def kind
      klass = record.is_a?(Class) ? record : record.class
      Junction::Kinds.for(klass.sti_name) ||
        raise(ArgumentError, "No registered kind for #{klass}")
    end
  end
end
