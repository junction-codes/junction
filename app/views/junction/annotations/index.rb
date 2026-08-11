# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # Index view for the annotations overview page shell.
      class Index < Views::Base
        # Initializes the view.
        #
        # @param breadcrumbs [Array<Hash>] Breadcrumb navigation items.
        def initialize(breadcrumbs: [])
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs: @breadcrumbs) do
            div(class: "px-6 py-3 space-y-6") do
              h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
                t(".title")
              end

              p(class: "text-sm text-gray-500 dark:text-gray-400") do
                t(".description")
              end

              secret_warning

              Tabs(default: "annotations") do |tabs|
                tabs.list do |list|
                  list.trigger(value: "annotations") { t(".annotations_tab") }
                  list.trigger(value: "entity_types") { t(".entity_type_tab") }
                end

                tabs.content(value: "annotations") do
                  turbo_frame_tag "annotations_keys",
                                  src: annotation_keys_path,
                                  loading: :lazy do
                    div(class: "p-4") { Skeleton(class: "h-20") }
                  end
                end

                tabs.content(value: "entity_types") do
                  turbo_frame_tag "annotations_entity_types",
                                  src: annotation_entity_types_path,
                                  loading: :lazy do
                    div(class: "p-4") { Skeleton(class: "h-20") }
                  end
                end
              end
            end
          end
        end

        private

        # Warns that annotations are not a suitable place for secrets.
        def secret_warning
          Alert(variant: :warning, dismissible: false) do |alert|
            alert.description { t(".secret_warning") }
          end
        end
      end
    end
  end
end
