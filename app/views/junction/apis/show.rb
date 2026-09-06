# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Detail page for an API.
      #
      # Rendering lives in {Entities::Show}; this adds the definition tab and
      # resolves the copy in the API translation scope.
      class Show < Entities::Show
        private

        def meta_rows
          owner_row
          type_row
        end

        def type_row
          meta_row(@entity.class.human_attribute_name(:type)) do
            span { plain @entity.type }
          end
        end

        def parent_link
          related_link(@entity.system, :part_of_system, :system_title)
        end

        def tab_triggers(list)
          list.trigger(value: "definition") do
            icon("file-text", class: "pe-2")
            plain @entity.class.human_attribute_name(:definition)
          end
        end

        def tab_panes(tabs)
          tabs.content(value: "definition") { definition_section }
        end

        def definition_section
          div do
            h3(class: "text-xl font-semibold text-gray-800 dark:text-white mb-4") do
              @entity.class.human_attribute_name(:definition)
            end

            Tabs(default_value: "raw") do |tabs|
              tabs.list { |list| list.trigger(value: "raw") { t(".raw") } }

              tabs.content(value: "raw", class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                if @entity.definition.present?
                  pre(class: "bg-gray-100 dark:bg-gray-900 p-4 rounded-lg overflow-x-auto") do
                    code(class: "language-yaml") { plain @entity.definition }
                  end
                else
                  p(class: "text-gray-600 dark:text-gray-400") { t(".no_definition") }
                end
              end
            end
          end
        end
      end
    end
  end
end
