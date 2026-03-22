# frozen_string_literal: true

module Junction
  module Views
    module Shared
      # Lazy-loaded turbo frame content for a dependents table.
      class Dependents < Views::Base
        # Initializes the view.
        #
        # @param dependents [Array<Junction::Dependency>] The dependents to
        #   display in the table.
        def initialize(dependents:)
          @dependents = dependents
        end

        def view_template
          turbo_frame_tag "dependents" do
            render Table.new do |table|
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
          end
        end
      end
    end
  end
end
