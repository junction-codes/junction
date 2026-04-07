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

            div(class: "absolute left-0 right-0 z-50 mt-1 shadow-lg bg-white dark:bg-gray-800 rounded-md") do
              AutocompleteResultList do
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
            href: url_for(entity),
            data: { turbo_frame: "_top" },
            class: "flex items-center justify-between px-3 py-2 cursor-pointer " \
                   "hover:bg-gray-100 dark:hover:bg-gray-700 " \
                   "focus:bg-gray-100 dark:focus:bg-gray-700 " \
                   "focus:outline-none"
          ) do
            span(class: "text-sm font-medium text-gray-900 dark:text-white") { entity.title }
            span(class: "text-xs text-gray-500 dark:text-gray-400") do
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
            class: "flex items-center justify-center px-3 py-2 text-xs text-blue-600 " \
                   "dark:text-blue-400 hover:underline border-t " \
                   "border-gray-100 dark:border-gray-700"
          ) do
            t(".see_all", query: @query)
          end
        end
      end
    end
  end
end
