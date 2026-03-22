# frozen_string_literal: true

module Junction
  module Views
    module Shared
      # Lazy-loaded turbo frame content for a dependency table.
      class Dependencies < Views::Base
        # Initializes the view.
        #
        # @param dependencies [Array<Junction::Dependency>] The dependencies to
        #   display in the table.
        def initialize(dependencies:)
          @dependencies = dependencies
        end

        def view_template
          turbo_frame_tag "dependencies" do
            render Table.new do |table|
              table.header do |header|
                header.row do |row|
                  row.head { t("views.shared.dependencies.name") }
                  row.head { t("views.shared.dependencies.type") }
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
          end
        end
      end
    end
  end
end
