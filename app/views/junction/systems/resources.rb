# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Lazy-loaded turbo frame content for a system's resources table.
      class Resources < Views::Base
        # Initializes the view.
        #
        # @param resources [Array<Junction::Resource>] The resources to
        #   display in the table.
        def initialize(resources:)
          @resources = resources
        end

        def view_template
          turbo_frame_tag "system_resources" do
            Table do |table|
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
          end
        end
      end
    end
  end
end
