# frozen_string_literal: true

module Junction
  module Views
    module Shared
      # Lazy-loaded turbo frame content for a dependents table.
      class Dependents < Views::Base
        attr_reader :page_url, :per_page_url, :pagy

        # Initializes the view.
        #
        # @param dependents [Array<Junction::Dependency>] The dependents to
        #   display in the table.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param page_url [#call] Callable that accepts a page number and
        #   returns a URL string preserving current filters, sort, and per_page.
        # @param per_page_url [#call] Callable that accepts a per_page
        #   integer and returns a URL string.
        def initialize(dependents:, pagy:, page_url:, per_page_url:)
          @dependents = dependents
          @pagy = pagy
          @page_url = page_url
          @per_page_url = per_page_url
        end

        def view_template
          turbo_frame_tag "dependents" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.shared.dependents.name") }
                  row.head { t("views.shared.dependents.type") }
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

            PaginationNav(pagy:, page_url:, per_page_url:, turbo_action: nil, turbo_frame: "dependents")
          end
        end
      end
    end
  end
end
