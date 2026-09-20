# frozen_string_literal: true

module Junction
  module Views
    module Domains
      # Detail page for a Domain.
      #
      # Rendering lives in {Entities::Show}. This adds what a domain has of its
      # own: the domain above it, and the systems within it.
      class Show < Entities::Show
        private

        def related_items
          related_item(@entity.parent, @entity.class.human_attribute_name(:parent_id))
        end

        def tab_triggers(list)
          tab_trigger(list, "systems", Junction::System.model_name.human(count: 2),
                      @entity.systems.count)
        end

        def tab_panes(tabs)
          pane(tabs, "systems") do
            turbo_frame_tag "domain_systems",
                            src: junction_systems_domain_path(@entity),
                            loading: :lazy do
              div(class: "p-4") { Skeleton(class: "h-20") }
            end
          end
        end
      end
    end
  end
end
