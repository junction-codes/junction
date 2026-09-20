# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Detail page for an API.
      #
      # Rendering lives in {Entities::Show}. This adds where an API sits and its
      # definition tab, and resolves the copy in the API translation scope.
      class Show < Entities::Show
        private

        def related_items
          related_item(@entity.system, @entity.class.human_attribute_name(:system_id))
          related_item(@entity.system&.domain, @entity.class.human_attribute_name(:domain_id))
        end

        def tab_triggers(list)
          tab_trigger(list, "definition", @entity.class.human_attribute_name(:definition))
        end

        def tab_panes(tabs)
          pane(tabs, "definition") { definition_section }
        end

        def definition_section
          EntityCard(title: @entity.class.human_attribute_name(:definition)) do
            if @entity.definition.present?
              pre(class: "rounded-lg bg-inset p-4 overflow-x-auto font-mono " \
                         "text-[12.5px] text-text-strong") do
                code(class: "language-yaml") { plain @entity.definition }
              end
            else
              p(class: "text-[12px] text-muted-foreground") { t(".no_definition") }
            end
          end
        end
      end
    end
  end
end
