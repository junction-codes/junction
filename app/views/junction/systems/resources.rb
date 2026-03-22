# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Lazy-loaded turbo frame content for a system's resources table.
      class Resources < Views::Base
        attr_reader :page_url, :per_page_url, :pagy

        # Initializes the view.
        #
        # @param resources [Array<Junction::Resource>] The resources to
        #   display in the table.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param page_url [#call] Callable that accepts a page number and
        #   returns a URL string preserving current filters, sort, and per_page.
        # @param per_page_url [#call] Callable that accepts a per_page
        #   integer and returns a URL string.
        def initialize(resources:, pagy:, page_url:, per_page_url:)
          @resources = resources
          @pagy = pagy
          @page_url = page_url
          @per_page_url = per_page_url
        end

        def view_template
          turbo_frame_tag "system_resources" do
            Table(class: "rounded-lg shadow overflow-hidden") do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.systems.entities.name") }
                  row.head { t("views.systems.entities.type") }
                end
              end

              table.body do |body|
                @resources.each do |resource|
                  body.row do |row|
                    row.cell { render_view_link(resource) }
                    row.cell { resource.type }
                  end
                end
              end
            end

            PaginationNav(pagy:, page_url:, per_page_url:, turbo_action: nil, turbo_frame: "system_resources")
          end
        end
      end
    end
  end
end
