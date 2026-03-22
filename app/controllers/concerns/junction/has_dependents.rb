# frozen_string_literal: true

module Junction
  module HasDependents
    extend ActiveSupport::Concern

    # GET /:resource/:id/dependents
    def dependents
      authorize! @entity, to: :show?
      render Views::Shared::Dependents.new(dependents: dependent_list)
    end

    private

    def dependent_list
      (
        @entity.api_dependents +
        @entity.component_dependents +
        @entity.resource_dependents
      ).sort_by(&:name)
    end
  end
end
