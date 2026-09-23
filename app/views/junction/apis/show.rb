# frozen_string_literal: true

module Junction
  module Views
    module Apis
      # Detail page for an API.
      #
      # Rendering lives in {Entities::Show}. This adds the API definition tab.
      class Show < Entities::Show
        private

        # The spec itself, which is a pane of its own rather than a list of
        # other entities, so it is not a `detail_tabs` entry.
        def tab_triggers(list)
          super

          tab_trigger(list, "definition", @entity.class.human_attribute_name(:definition))
        end

        def tab_panes(tabs)
          super

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
