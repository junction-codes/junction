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
    # Permission context for the record under authorization.
    #
    # @return [String] The context.
    # @raise [ArgumentError] If the record's kind is not registered.
    def context
      klass = record.is_a?(Class) ? record : record.class
      kind = Junction::Kinds.for(klass.sti_name)
      return kind.context if kind

      raise ArgumentError, "No registered kind for #{klass}"
    end
  end
end
