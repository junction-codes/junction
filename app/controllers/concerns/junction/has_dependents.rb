# frozen_string_literal: true

module Junction
  module HasDependents
    extend ActiveSupport::Concern

    # GET /:resource/:id/dependents
    def dependents
      authorize! @entity, to: :show?
      @pagy, entities = paginate(dependent_list)

      render Views::Shared::Dependents.new(
        dependents: entities,
        pagy: @pagy,
        page_url: ->(page) { url_for(page:, per_page: @pagy.options[:limit]) },
        per_page_url: ->(per_page) { url_for(per_page:) }
      )
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
