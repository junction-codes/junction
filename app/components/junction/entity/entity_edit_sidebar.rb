# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Renders the sidebar beside the edit form with read-only metadata and the
      # danger zone.
      #
      # Identical for every kind. Kinds subclass this so the delete copy names
      # the right thing in their own translation scope.
      class EntityEditSidebar < Base
        include Junction::EntityCopy

        share_translations

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity being edited.
        # @param can_destroy [Boolean] Whether the entity may be deleted.
        def initialize(entity:, can_destroy: true)
          @entity = entity
          @can_destroy = can_destroy

          super()
        end

        def view_template
          metadata_card
          danger_zone if @can_destroy
        end

        private

        # Renders the read-only metadata card.
        def metadata_card
          Card do |card|
            card.header { card.title { t(".metadata") } }
            card.content do
              dl(class: "divide-y divide-gray-200 dark:divide-gray-700") do
                metadata_row(@entity.class.human_attribute_name(:created_at),
                             @entity.created_at.strftime("%b %d, %Y"))
                metadata_row(@entity.class.human_attribute_name(:updated_at),
                             @entity.updated_at.strftime("%b %d, %Y"))
              end
            end
          end
        end

        # Renders the destructive actions card.
        def danger_zone
          Card(class: "border-red-500/50 dark:border-red-500/30") do |card|
            card.header do
              card.title(class: "text-red-700 dark:text-red-400") { t(".danger_zone") }
            end

            card.content(class: "space-y-4") do
              p(class: "text-sm text-gray-600 dark:text-gray-400") { t(".danger_zone_warning") }

              delete_dialog
            end
          end
        end

        # Renders the delete button and its confirmation dialog.
        def delete_dialog
          Dialog do |dialog|
            dialog.trigger do
              Button(variant: :destructive, class: "w-full justify-center") do
                icon("trash", class: "w-4 h-4 mr-2")
                plain t(".delete")
              end
            end

            dialog.content do |content|
              content.header { |h| h.title { t(".delete_confirm_title") } }
              content.body { t(".delete_confirm_body") }
              content.footer do
                Link(data: { action: "click->ruby-ui--dialog#dismiss" }) { t(".cancel") }
                Link(variant: :destructive, href: junction_catalog_path(@entity),
                     data_turbo_method: :delete) { t(".confirm_delete") }
              end
            end
          end
        end

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end

        # Renders one metadata row.
        #
        # @param label [String] The row's label.
        # @param value [String] The row's value.
        def metadata_row(label, value)
          div(class: "py-3 flex justify-between text-sm") do
            dt(class: "font-medium text-gray-600 dark:text-gray-400") { label }
            dd(class: "text-gray-900 dark:text-white") { value }
          end
        end
      end
    end
  end
end
