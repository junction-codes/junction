# frozen_string_literal: true

module Junction
  module Views
    module Search
      # Turbo Frame response for the header search autocomplete dropdown.
      class Autocomplete < Views::Base
        # Initializes a new view.
        #
        # @param query [String] The search query.
        # @param results [Array<ApplicationRecord>] The search results.
        def initialize(query:, results:)
          @query = query
          @results = results
        end

        def view_template
          turbo_frame_tag "global-search-results" do
            next if @results.empty?

            div(class: "absolute left-0 right-0 z-50 mt-1 shadow-lg bg-surface rounded-md") do
              ResultList do
                @results.each { |entity| result_link(entity) }

                see_all_link
              end
            end
          end
        end

        private

        # Renders the link for an individual search result.
        #
        # @param entity [ApplicationRecord] The entity to link to.
        def result_link(entity)
          a(
            href: junction_catalog_path(entity),
            data: { turbo_frame: "_top" },
            class: "flex items-center justify-between px-3 py-2 cursor-pointer " \
                   "hover:bg-accent focus:bg-accent focus:outline-none"
          ) do
            span(class: "text-sm font-medium text-foreground") { entity.title }
            span(class: "text-xs text-text-tertiary") do
              plain entity.class.model_name.human
              if entity.respond_to?(:type) && entity.type.present?
                plain " · #{entity.type.to_s.humanize}"
              end
            end
          end
        end

        # Renders the link to see all results for the query.
        def see_all_link
          a(
            href: search_path(q: @query),
            data: { turbo_frame: "_top" },
            class: "flex items-center justify-center px-3 py-2 text-xs " \
                   "text-accent-strong hover:underline border-t border-border"
          ) do
            t(".see_all", query: @query)
          end
        end
      end
    end
  end
end
