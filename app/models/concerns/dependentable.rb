# frozen_string_literal: true

# Concern for models that can depend on others.
module Dependentable
  extend ActiveSupport::Concern

  included do
    has_many :dependencies, as: :source, class_name: "Dependency", dependent: :destroy
    has_many :dependent_apis,
             through: :dependencies,
             source: :target,
             source_type: "Api"
    has_many :dependent_components,
             through: :dependencies,
             source: :target,
             source_type: "Component"
    has_many :dependent_resources,
             through: :dependencies,
             source: :target,
             source_type: "Resource"
  end
end
