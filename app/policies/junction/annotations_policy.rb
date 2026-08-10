# frozen_string_literal: true

module Junction
  # Access control policy for the annotations overview page.
  class AnnotationsPolicy < Junction::ApplicationPolicy
    alias_rule :keys?, :entity_types?, :annotation_key?, :entity_type?, to: :index?

    def context
      "annotations"
    end
  end
end
