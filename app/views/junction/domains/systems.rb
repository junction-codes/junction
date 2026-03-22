# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Lazy-loaded turbo frame content for a domain's systems table.
      class Systems < Views::Base
        attr_reader :page_url, :per_page_url, :pagy

        # Initializes the view.
        #
        # @param systems [Array<Junction::System>] The systems to display in the
        #   table.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param page_url [#call] Callable that accepts a page number and
        #   returns a URL string preserving current filters, sort, and per_page.
        # @param per_page_url [#call] Callable that accepts a per_page
        #   integer and returns a URL string.
        def initialize(systems:, pagy:, page_url:, per_page_url:)
          @systems = systems
          @pagy = pagy
          @page_url = page_url
          @per_page_url = per_page_url
        end

        def view_template
          turbo_frame_tag "domain_systems" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.domains.systems.name") }
                  row.head { t("views.domains.systems.status") }
                end
              end

              table.body do |body|
                @systems.each do |system|
                  body.row do |row|
                    row.cell { render_view_link(system) }
                    row.cell do
                      Badge(variant: system.status.to_sym) { system.status.titleize }
                    end
                  end
                end
              end
            end

            PaginationNav(pagy:, page_url:, per_page_url:, turbo_action: nil,
                          turbo_frame: "domain_systems")
          end
        end
      end
    end
  end
end
