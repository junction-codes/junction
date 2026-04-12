# frozen_string_literal: true

module Junction
  module Components
    module Dashboard
      # Component to display metadata for an individual catalog entity.
      class DashboardEntityMetadata < Base
        # Initializes the component.
        #
        # @param entity [ApplicationRecord] The catalog entity.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(entity:, **user_attrs)
          @entity = entity

          super(**user_attrs)
        end

        def view_template(&)
          div(**attrs) do
            Badge(variant: :primary) { @entity.model_name.human }

            if @entity.respond_to?(:lifecycle) && @entity.lifecycle.present?
              Badge(variant: @entity.lifecycle) { @entity.lifecycle.titleize }
            end

            if @entity.respond_to?(:status) && @entity.status.present?
              Badge(variant: @entity.status) { @entity.status.titleize }
            end
          end

          association_link(
            :system,
            t(".entity_label", model: Junction::System.model_name.human)
          )
          association_link(
            :domain,
            t(".entity_label", model: Junction::Domain.model_name.human)
          )
          association_link(
            :owner,
            t(".entity_label", model: ApplicationRecord.human_attribute_name(:owner_id))
          )
        end

        private

        def default_attrs
          { class: "flex flex-wrap items-center gap-2" }
        end

        # Renders a link to an associated record if it exists.
        #
        # @param association [Symbol] The association name.
        # @param label [String] The label to display before the link.
        def association_link(association, label)
          return unless @entity.respond_to?(association) && @entity.public_send(association).present?

          div(class: "text-sm text-gray-600 dark:text-gray-400 flex items-center gap-1 min-w-[15em]") do
            span(class: "shrink-0") { label }
            render_view_link(@entity.public_send(association), class: "ps-0")
          end
        end
      end
    end
  end
end
