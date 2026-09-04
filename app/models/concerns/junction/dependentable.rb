# frozen_string_literal: true

module Junction
  # Concern for entities that can depend on others.
  #
  # Kind-specific collections are scoped by `kind` on the target rather than by
  # a polymorphic type column: under single table inheritance Rails writes the
  # base class name to a polymorphic type, which would collapse every one of
  # these into the same query.
  module Dependentable
    extend ActiveSupport::Concern

    included do
      has_many :dependencies, -> { depends_on },
               class_name: "Junction::Relation", foreign_key: :source_id,
               inverse_of: :source

      has_many :dependency_targets, through: :dependencies, source: :target

      has_many :dependent_apis, -> { where(kind: "Api") },
               through: :dependencies, source: :target
      has_many :dependent_components, -> { where(kind: "Component") },
               through: :dependencies, source: :target
      has_many :dependent_resources, -> { where(kind: "Resource") },
               through: :dependencies, source: :target
    end
  end
end
