# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # Lazy-loaded annotations key tab list.
      class Keys < Views::Base
        # Initializes the view.
        #
        # @param annotation_key_tabs [Array<Hash>] List of annotation key tabs.
        # @param breadcrumbs [Array<Hash>] Breadcrumb navigation items.
        def initialize(annotation_key_tabs:, breadcrumbs: [])
          @annotation_key_tabs = annotation_key_tabs
          @breadcrumbs = breadcrumbs
        end

        def view_template
          turbo_frame_tag "annotations_keys" do
            if @annotation_key_tabs.empty?
              p(class: "text-sm text-gray-500 dark:text-gray-400") { t(".empty") }
              next
            end

            Tabs(
              default: @annotation_key_tabs.first.fetch(:id),
              class: "grid grid-cols-1 lg:grid-cols-4 gap-6 items-start"
            ) do |tabs|
              tabs.list(class: "flex h-auto flex-col w-full items-stretch rounded-lg bg-muted p-2") do |list|
                @annotation_key_tabs.each do |tab|
                  list.trigger(value: tab.fetch(:id), class: "w-full justify-between px-3 py-2") do
                    span(class: "truncate font-mono text-xs") { tab.fetch(:label) }
                    Badge(variant: :secondary, size: :sm) { tab.fetch(:total_count) }
                  end
                end
              end

              div(class: "lg:col-span-3") do
                @annotation_key_tabs.each do |tab|
                  tabs.content(value: tab.fetch(:id), class: "mt-0") do
                    turbo_frame_tag "annotation_key_#{tab.fetch(:id)}",
                                    src: annotation_key_path(tab.fetch(:id)),
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
