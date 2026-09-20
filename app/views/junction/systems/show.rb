# frozen_string_literal: true

module Junction
  module Views
    module Systems
      # Detail page for a System.
      #
      # Rendering lives in {Entities::Show}; this adds what a system has of its
      # own: the domain it belongs to, and a tab for each kind that makes it
      # up.
      class Show < Entities::Show
        # The kinds a system is made of, in tab order.
        PARTS = %i[apis components resources].freeze

        private

        def related_items
          related_item(@entity.domain, @entity.class.human_attribute_name(:domain_id))
        end

        def tab_triggers(list)
          PARTS.each do |plural|
            tab_trigger(list, plural.to_s, part_kind(plural).model_name.human(count: 2),
                        @entity.public_send(plural).count)
          end
        end

        def tab_panes(tabs)
          PARTS.each do |plural|
            pane(tabs, plural.to_s) do
              turbo_frame_tag "system_#{plural}",
                              src: public_send(:"junction_#{plural}_system_path", @entity),
                              loading: :lazy do
                div(class: "p-4") { Skeleton(class: "h-20") }
              end
            end
          end
        end

        def part_kind(plural)
          Junction::Kinds.by_scope(plural.to_s.singularize).model
        end
      end
    end
  end
end
