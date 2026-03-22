# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Lazy-loaded turbo frame content for a system's components table.
      class Components < Views::Base
        # Initializes the view.
        #
        # @param components [Array<Junction::Component>] The components to
        #   display in the table.
        def initialize(components:)
          @components = components
        end

        def view_template
          turbo_frame_tag "system_components" do
            Table do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.systems.entities.name") }
                  row.head { t("views.systems.entities.lifecycle") }
                end
              end

              table.body do |body|
                @components.each do |component|
                  body.row do |row|
                    row.cell { render_view_link(component) }
                    row.cell do
                      Badge(variant: component.lifecycle&.to_sym) { component.lifecycle&.titleize }
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
