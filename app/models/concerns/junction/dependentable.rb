# frozen_string_literal: true

module Junction
  # Concern for models that can depend on others.
  module Dependentable
    extend ActiveSupport::Concern

    included do
      has_many :dependencies,
              as: :source,
              class_name: "Junction::Dependency",
              dependent: :destroy

      has_many :dependent_apis,
              through: :dependencies,
              source: :target,
              source_type: "Junction::Api"
      has_many :dependent_components,
              through: :dependencies,
              source: :target,
              source_type: "Junction::Component"
      has_many :dependent_resources,
              through: :dependencies,
              source: :target,
              source_type: "Junction::Resource"
    end
  end
end
