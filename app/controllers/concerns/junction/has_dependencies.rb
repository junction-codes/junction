# frozen_string_literal: true

module Junction
  module HasDependencies
    extend ActiveSupport::Concern

    # GET /:resource/:id/dependencies
    def dependencies
      authorize! @entity, to: :show?
      render Views::Shared::Dependencies.new(dependencies: dependency_list)
    end

    private

    def dependency_list
      (
        @entity.dependent_apis +
        @entity.dependent_components +
        @entity.dependent_resources
      ).sort_by(&:name)
    end
  end
end
