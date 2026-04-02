# frozen_string_literal: true

module Junction
  module Views
    module Dependents
      # Lazy-loaded turbo frame content for a dependents table.
      class Index < Views::Base
        attr_reader :page_url, :pagy, :per_page_url, :query, :sort_url

        # Initializes the view.
        #
        # @param dependents [Array<Junction::Dependency>] The dependents to
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
        def initialize(dependents:, pagy:, query:, page_url:, per_page_url:,
                       sort_url:)
          @dependents = dependents
          @pagy = pagy
          @query = query
          @page_url = page_url
          @per_page_url = per_page_url
          @sort_url = sort_url
        end

        def view_template
          turbo_frame_tag "dependents" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  %w[name type].each do |field|
                    row.sortable_head(field:, sort_url:, **sort_attrs(query, field)) do
                      t(".#{field}")
                    end
                  end
                end
              end

              table.body do |body|
                @dependents.each do |dependent|
                  body.row do |row|
                    row.cell { render_view_link(dependent) }
                    row.cell { dependent.type }
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
