# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # Lazy-loaded entity-type tab list.
      class EntityTypes < Views::Base
        # Initializes the view.
        #
        # @param entity_type_tabs [Array<Hash>] List of entity type tabs.
        # @param breadcrumbs [Array<Hash>] Breadcrumb navigation items.
        def initialize(entity_type_tabs:, breadcrumbs: [])
          @entity_type_tabs = entity_type_tabs
          @breadcrumbs = breadcrumbs
        end

        def view_template
          turbo_frame_tag "annotations_entity_types" do
            if @entity_type_tabs.empty?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { t(".empty_entity_types") }
              next
            end

            Tabs(
              default: @entity_type_tabs.first.fetch(:id),
              class: "grid grid-cols-1 lg:grid-cols-4 gap-6 items-start"
            ) do |tabs|
              tabs.list(class: "flex h-auto flex-col w-full items-stretch rounded-lg bg-muted p-2") do |list|
                @entity_type_tabs.each do |tab|
                  list.trigger(value: tab.fetch(:id), class: "w-full justify-between px-3 py-2") do
                    span { tab.fetch(:label) }
                    Badge(variant: :secondary, size: :sm) { tab.fetch(:total_count) }
                  end
                end
              end

              div(class: "lg:col-span-3") do
                @entity_type_tabs.each do |tab|
                  tabs.content(value: tab.fetch(:id), class: "mt-0") do
                    turbo_frame_tag "annotation_entity_type_#{tab.fetch(:id)}",
                                    src: annotation_entity_type_path(tab.fetch(:id)),
                                    loading: :lazy do
                      div(class: "p-4") { Skeleton(class: "h-20") }
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
end
