# frozen_string_literal: true

# Concern for models that can be the target of a dependency.
module Dependable
  extend ActiveSupport::Concern

  included do
    has_many :dependents, as: :target, class_name: "Dependency", dependent: :destroy
    has_many :component_dependents,
             through: :dependents,
             source: :source,
             source_type: "Component"
    has_many :resource_dependents,
             through: :dependents,
             source: :source,
             source_type: "Resource"
  end
end
