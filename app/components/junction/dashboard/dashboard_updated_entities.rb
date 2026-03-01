# frozen_string_literal: true

module Junction
  module Components
    # Component to display recently updated catalog entities.
    class DashboardUpdatedEntities < Base
      # Initializes the component.
      #
      # @param entities [Array<ApplicationRecord>] List of recently updated
      #   catalog entities.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(entities:, **user_attrs)
        @entities = entities

        super(**user_attrs)
      end

      def view_template(&)
        Components::Card(**attrs) do |card|
          card.header do |header|
            header.title(class: "text-lg font-semibold text-gray-900 dark:text-white") do
              t("dashboard.updated_entities.title")
            end

            header.description(class: "text-gray-600 dark:text-gray-400") do
              t("dashboard.updated_entities.description")
            end
          end

          card.content { entities_list }
        end
      end

      private

      # Renders the list of entities owned by the user.
      def entities_list
        return empty_list if @entities.empty?

        ul(class: "divide-y divide-gray-200 dark:divide-gray-700") do
          @entities.each do |entity|
            li(class: "py-4") do
              div(class: "flex items-start justify-between gap-3") do
                div(class: "min-w-0") do
                  div(class: "flex items-center gap-2") do
                    icon(entity.icon, class: "h-4 w-4 text-gray-500 shrink-0")
                    Link(href: url_for(entity), class: "p-0") do
                      span(class: "inline-block max-w-[10em] truncate", title: entity.name) do
                        entity.name
                      end
                    end
                  end

                  div(class: "mt-1") do
                    DashboardEntityMetadata(entity:)
                  end
                end

                render Components::RelativeTime.new(
                  time: entity.updated_at,
                  class: "text-sm text-gray-500 dark:text-gray-400 whitespace-nowrap shrink-0"
                )
              end
            end
          end
        end
      end

      # Renders an appropriate message when there are no updated entities.
      def empty_list
        p(class: "text-sm text-gray-500 dark:text-gray-400 py-2") do
          t("dashboard.updated_entities.empty")
        end
      end
    end
  end
end
