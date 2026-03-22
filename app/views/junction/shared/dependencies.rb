# frozen_string_literal: true

module Junction
  module Views
    module Shared
      # Lazy-loaded turbo frame content for a dependency table.
      class Dependencies < Views::Base
        attr_reader :page_url, :pagy, :per_page_url, :query, :sort_url

        # Initializes the view.
        #
        # @param dependencies [Array<Junction::Dependency>] The dependencies to
        #   display in the table.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param query [Ransack::Search] Ransack query for sorting and
        #   filtering.
        # @param page_url [#call] Callable that accepts a page number and
        #   returns a URL string preserving current filters, sort, and per_page.
        # @param per_page_url [#call] Callable that accepts a per_page
        #   integer and returns a URL string.
        # @param sort_url [#call] Callable that accepts a field and direction
        #   and returns a URL string.
        def initialize(dependencies:, pagy:, query:, page_url:, per_page_url:,
                       sort_url:)
          @dependencies = dependencies
          @pagy = pagy
          @query = query
          @page_url = page_url
          @per_page_url = per_page_url
          @sort_url = sort_url
        end

        def view_template
          turbo_frame_tag "dependencies" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  row.sortable_head(query:, field: "name", sort_url:) { t("views.shared.dependencies.name") }
                  row.sortable_head(query:, field: "type", sort_url:) { t("views.shared.dependencies.type") }
                end
              end

              table.body do |body|
                @dependencies.each do |dependency|
                  body.row do |row|
                    row.cell { render_view_link(dependency) }
                    row.cell { dependency.type }
                  end
                end
              end
            end

            PaginationNav(pagy:, page_url:, per_page_url:, turbo_action: nil)
          end
        end
      end
    end
  end
end
