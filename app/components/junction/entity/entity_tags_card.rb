# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # An entity's tags and labels.
      class EntityTagsCard < Base
        include Junction::EntityCopy

        share_translations

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity.
        # @param edit_path [String] Edit path for the entity's tags and
        #   labels, if authorized.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(entity:, edit_path: nil, **user_attrs)
          @entity = entity
          @edit_path = edit_path

          super(**user_attrs)
        end

        def view_template
          EntityCard(title: t(".title"), action: edit_action, **attrs) do
            div(class: "grid grid-cols-1 md:grid-cols-2 gap-5 md:gap-0 " \
                       "md:divide-x md:divide-border") do
              half(t(".tags", count: tags.size), t(".tags_note"),
                   side: :start) { tag_chips }
              half(t(".labels", count: labels.size), t(".labels_note"),
                   side: :end) { label_chips }
            end
          end
        end

        private

        # Either panel of the card: tags or labels.
        #
        # @param caption [String] The caption.
        # @param note [String] Description of the panel.
        # @param side [Symbol] `:start` or `:end` of the divider.
        def half(caption, note, side:)
          div(class: EntityCard::SIDES.fetch(side)) do
            p(class: "text-[11px] font-semibold uppercase tracking-[0.06em] " \
                     "text-muted-foreground mb-2.5") { caption }
            yield
            p(class: "text-[11px] text-muted-foreground") { note }
          end
        end

        def tag_chips
          return none(t(".no_tags")) if tags.empty?

          chips do
            tags.each do |tag|
              li(class: "rounded-md bg-subtle px-2.5 py-1 text-[12px] " \
                        "font-medium text-text-body") { tag }
            end
          end
        end

        def label_chips
          return none(t(".no_labels")) if labels.empty?

          chips do
            labels.each do |key, value|
              li(class: "inline-flex items-center gap-1.5 text-[12px]") do
                span(class: "rounded-[5px] bg-subtle px-2 py-0.5 font-mono " \
                            "font-medium text-text-body") { key }
                whitespace
                span(class: "text-muted-foreground") { "=" }
                whitespace
                span(class: "font-mono text-text-body") { value.to_s }
              end
            end
          end
        end

        # A list, so the values are read out as separate items rather than
        # run together.
        def chips(&)
          ul(class: "flex flex-wrap items-center gap-2 mb-3", &)
        end

        def none(text)
          p(class: "text-[12px] text-muted-foreground mb-3") { text }
        end

        def edit_action
          [ t(".edit"), @edit_path ] if @edit_path
        end

        def tags
          @tags ||= Array(@entity.tags)
        end

        def labels
          @labels ||= @entity.labels.to_h
        end

        # Model class for the entity.
        #
        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end
      end
    end
  end
end
