# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Renders a role's metadata.
      #
      # The counts sit beside the editor because they are the stakes. A change
      # here lands on every one of those people at once.
      class RoleMetadataCard < Base
        # Initializes the component.
        #
        # @param role [Junction::Role] The role being edited.
        # @param reach [Hash] The number of entities that hold the role.
        # @option reach [Integer] :groups The number of groups holding the role.
        # @option reach [Integer] :people The number of people holding the role.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(role:, reach: {}, **user_attrs)
          @role = role
          @reach = reach

          super(**user_attrs)
        end

        def view_template
          return unless @role.persisted?

          Card(**attrs) do |card|
            card.header { |header| header.title(class: "text-[15px]") { t(".title") } }

            card.content do
              dl(class: "divide-y divide-border") do
                row(t(".created"), @role.created_at.to_date.to_formatted_s(:long))
                row(t(".updated"), @role.updated_at.to_date.to_formatted_s(:long))
                row(t(".groups"), @reach.fetch(:groups, 0).to_s)
                row(t(".people"), @reach.fetch(:people, 0).to_s)
              end
            end
          end
        end

        private

        # Renders one labelled value.
        #
        # @param label [String] The label describing the value.
        # @param value [String] The value itself.
        def row(label, value)
          div(class: "flex items-center justify-between gap-3 py-2 text-[12.5px]") do
            dt(class: "text-text-tertiary") { label }
            dd(class: "tabular-nums text-text-body") { value }
          end
        end
      end
    end
  end
end
