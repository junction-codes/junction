# frozen_string_literal: true

module Junction
  module HasDependencies
    extend ActiveSupport::Concern

    # GET /:resource/:id/dependencies
    def dependencies
      authorize! @entity, to: :show?
      @pagy, entities = paginate(dependency_list)

      render Views::Shared::Dependencies.new(
        dependencies: entities,
        pagy: @pagy,
        page_url: ->(page) { url_for(page:, per_page: @pagy.options[:limit]) },
        per_page_url: ->(per_page) { url_for(per_page:) }
      )
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
