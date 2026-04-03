# frozen_string_literal: true

module Junction
  module Views
    module Search
      # Full-page view for global catalog search results.
      class Index < Views::Base
        # Initializes a new view.
        #
        # @param query [String] The search query.
        # @param results [Array<ApplicationRecord>] The search results.
        # @param pagy [Pagy] The pagination object.
        # @param sort_field [String] Field to sort by.
        # @param sort_dir [String] Direction to sort by.
        def initialize(query:, results:, pagy:, sort_field:, sort_dir:)
          @query = query
          @results = results
          @pagy = pagy
          @sort_field = sort_field
          @sort_dir = sort_dir
        end

        def view_template
          render Layouts::Application.new do
            div(class: "px-6 py-6 space-y-6") do
              page_header
              render_results
            end
          end
        end

        private

        # Renders a page header for the search results.
        def page_header
          div do
            h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
              t("junction.views.search.index.title")
            end

            next unless @query.present?

            p(class: "mt-1 text-sm text-gray-500 dark:text-gray-400") do
              t("junction.views.search.index.result_count", count: @pagy.count, query: @query)
            end
          end
        end

        # Renders the search results table, or empty state if no results.
        def render_results
          return empty_state(t(".empty_query")) if @query.blank?
          return empty_state(t(".no_results", query: @query)) if @results.empty?

          div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
            Table do |table|
              table.header do |header|
                header.row do |row|
                  sort_url = ->(field, direction) {
                    search_path(
                      q: @query,
                      s: "#{field} #{direction}",
                      per_page: @pagy.options[:limit]
                    )
                  }

                  %w[name kind].each do |field|
                    row.sortable_head(field:, sort_url:, sorted: @sort_field == field, direction: @sort_dir) do
                      ApplicationRecord.human_attribute_name(field)
                    end
                  end

                  row.head { ApplicationRecord.human_attribute_name("owner_id") }
                end
              end

              table.body do |body|
                @results.each do |entity|
                  body.row do |row|
                    row.cell { EntityPreview(entity:) }
                    row.cell { kind_cell(entity) }
                    row.cell { render_view_link(entity.owner, class: "ps-0") if entity.respond_to?(:owner) }
                  end
                end
              end
            end
          end

          PaginationNav(
            pagy: @pagy,
            page_url: ->(page) {
              search_path(
                q: @query,
                s: "#{@sort_field} #{@sort_dir}",
                page:,
                per_page: @pagy.options[:limit]
              )
            },
            per_page_url: ->(per_page) {
              search_path(q: @query, s: "#{@sort_field} #{@sort_dir}", per_page:)
            }
          )
        end

        # Renders an empty state for the search results.
        def empty_state(message)
          div(class: "py-12 text-center") do
            icon("search", class: "mx-auto h-12 w-12 text-gray-300 dark:text-gray-600")
            p(class: "mt-4 text-sm text-gray-500 dark:text-gray-400") { message }
          end
        end

        # Renders the kind cell for a search result.
        def kind_cell(entity)
          kind = entity.class.model_name.human
          plain kind

          if entity.respond_to?(:type) && entity.type.present?
            plain " · #{entity.type.to_s.humanize}"
          end
        end
      end
    end
  end
end
