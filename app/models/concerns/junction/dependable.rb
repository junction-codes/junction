# frozen_string_literal: true

module Junction
  # Concern for models that can be the target of a dependency.
  module Dependable
    extend ActiveSupport::Concern

    included do
      has_many :dependents,
              as: :target,
              class_name: "Junction::Dependency",
              dependent: :destroy

      has_many :api_dependents,
              through: :dependents,
              source: :source,
              source_type: "Junction::Api"
      has_many :component_dependents,
              through: :dependents,
              source: :source,
              source_type: "Junction::Component"
      has_many :resource_dependents,
              through: :dependents,
              source: :source,
              source_type: "Junction::Resource"
    end
  end
end
