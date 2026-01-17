# frozen_string_literal: true

module Junction
  module Components
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
          Components::Badge(variant: :primary) { @entity.model_name.human }

          if @entity.respond_to?(:lifecycle) && @entity.lifecycle.present?
            Components::Badge(variant: @entity.lifecycle) { @entity.lifecycle.titleize }
          end

          if @entity.respond_to?(:status) && @entity.status.present?
            Components::Badge(variant: @entity.status) { @entity.status.titleize }
          end
        end

        association_link(:system, t("dashboard.my_entities.system_label"))
        association_link(:domain, t("dashboard.my_entities.domain_label"))
        association_link(:owner, t("dashboard.my_entities.owner_label"))
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

        record = @entity.public_send(association)
        div(class: "text-sm text-gray-600 dark:text-gray-400 flex items-center gap-1 min-w-[15em]") do
          span(class: "shrink-0") { label }
          Link(href: polymorphic_path(record), class: "p-0 flex-1 min-w-0 justify-start") do
            span(class: "inline-block truncate", title: record.name) { record.name }
          end
        end
      end
    end
  end
end
