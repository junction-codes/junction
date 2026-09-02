# frozen_string_literal: true

module Junction
  # Concern for entities that can be the target of a dependency.
  #
  # The mirror of {Junction::Dependentable}: these collections read the same
  # edges from the other end.
  module Dependable
    extend ActiveSupport::Concern

    included do
      has_many :dependents, -> { depends_on },
               class_name: "Junction::Relation", foreign_key: :target_id,
               inverse_of: :target

      has_many :dependent_sources, through: :dependents, source: :source

      has_many :api_dependents, -> { where(kind: "Api") },
               through: :dependents, source: :source
      has_many :component_dependents, -> { where(kind: "Component") },
               through: :dependents, source: :source
      has_many :resource_dependents, -> { where(kind: "Resource") },
               through: :dependents, source: :source
    end
  end
end
