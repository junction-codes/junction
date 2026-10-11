# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Renders the danger zone for a role.
      #
      # Deleting a role takes its permissions away from every group holding it
      # at once, so the warning declares how many will be impacted rather than
      # asking in the abstract.
      class RoleDangerCard < Base
        # Initializes the component.
        #
        # @param role [Junction::Role] The role being edited.
        # @param groups [Integer] How many groups hold the role.
        # @param can_destroy [Boolean] Whether the user may delete it.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(role:, groups: 0, can_destroy: false, **user_attrs)
          @role = role
          @groups = groups
          @can_destroy = can_destroy

          super(**user_attrs)
        end

        def view_template
          return system_note if @role.system?
          return unless @can_destroy && @role.persisted?

          Card(class: "border-destructive/30") do |card|
            card.header do |header|
              header.title(class: "text-[15px] text-destructive") { t(".title") }
            end

            card.content(class: "space-y-4") do
              p(class: "text-[12.5px] leading-5 text-text-tertiary") { warning }
              delete_dialog
            end
          end
        end

        private

        # Returns the warning, naming how many groups lose the role with it.
        #
        # @return [String] The warning.
        def warning
          t(".warning", count: @groups)
        end

        # Renders the note shown in place of the danger zone for a system role.
        def system_note
          p(class: "text-[11.5px] leading-5 text-text-tertiary") { t(".system_note") }
        end

        # Renders the delete button and the confirmation it opens.
        def delete_dialog
          Dialog do |dialog|
            dialog.trigger do
              Button(variant: :outline, type: "button",
                     class: "w-full justify-center border-destructive/40 " \
                            "text-destructive") do
                icon("trash", class: "w-4 h-4 mr-2")
                plain t(".delete")
              end
            end

            dialog.content do |content|
              content.header { |header| header.title { t(".confirm_title") } }
              content.body { warning }
              content.footer do
                Link(data: { action: "click->ruby-ui--dialog#dismiss" }) { t(".cancel") }
                Link(variant: :destructive, href: junction_catalog_path(@role),
                     data_turbo_method: :delete) { t(".confirm") }
              end
            end
          end
        end
      end
    end
  end
end
