# frozen_string_literal: true

module Junction
  module HasDependencies
    extend ActiveSupport::Concern

    private

    def dependencies
      (
        @entity.dependent_apis +
        @entity.dependent_components +
        @entity.dependent_resources
      ).sort_by(&:name)
    end
  end
end
