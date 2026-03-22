# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Lazy-loaded turbo frame content for a system's APIs table.
      class Apis < Views::Base
        # Initializes the view.
        #
        # @param apis [Array<Junction::Api>] The APIs to display in the table.
        def initialize(apis:)
          @apis = apis
        end

        def view_template
          turbo_frame_tag "system_apis" do
            Table do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.systems.entities.name") }
                  row.head { t("views.systems.entities.type") }
                end
              end

              table.body do |body|
                @apis.each do |api|
                  body.row do |row|
                    row.cell { render_view_link(api) }
                    row.cell { api.type }
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
