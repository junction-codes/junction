# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Lazy-loaded turbo frame content for a domain's systems table.
      class Systems < Views::Base
        # Initializes the view.
        #
        # @param systems [Array<Junction::System>] The systems to display in the
        #   table.
        def initialize(systems:)
          @systems = systems
        end

        def view_template
          turbo_frame_tag "domain_systems" do
            Table do |table|
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
          end
        end
      end
    end
  end
end
