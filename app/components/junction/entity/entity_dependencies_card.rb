# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Overview of an entity's dependencies and dependents.
      class EntityDependenciesCard < Base
        include Junction::EntityCopy

        share_translations

        # Number of each to show before adding an overflow indicator.
        SHOWN = 4

        # Initializes the component.
        #
        # @param entity [Junction::Entity] The entity to render the card for.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(entity:, **user_attrs)
          @entity = entity

          super(**user_attrs)
        end

        def view_template
          EntityCard(title: t(".title"), **attrs) do
            div(class: "grid grid-cols-1 md:grid-cols-2 gap-5 md:gap-0 " \
                       "md:divide-x md:divide-border") do
              column(:depends_on, @entity.dependency_targets, side: :start)
              column(:used_by, @entity.dependent_sources, side: :end)
            end
          end
        end

        private

        # A single column of the card.
        #
        # Associated entities are counted and fetched separately, so a busy
        # service doesn't load every dependent to show four of them.
        #
        # @param key [Symbol] The column, naming its copy.
        # @param relation [ActiveRecord::Relation] Every entity from the
        #   association.
        # @param side [Symbol] `:start` or `:end` of the divider, which each
        #   keeps clear of.
        def column(key, relation, side:)
          total = relation.count

          div(class: EntityCard::SIDES.fetch(side)) do
            p(class: "text-[11px] font-semibold uppercase tracking-[0.06em] " \
                     "text-muted-foreground mb-3") { t(".#{key}", count: total) }

            if total.zero?
              p(class: "text-[12px] text-muted-foreground") { t(".#{key}_none") }
            else
              ul(class: "space-y-2.5") do
                relation.order(:title).limit(SHOWN).each { |entity| row(entity) }
              end

              more(total - SHOWN)
            end
          end
        end

        # A single row representing an associated entity.
        #
        # @param entity [Junction::Entity] The related entity.
        def row(entity)
          li(class: "flex items-center gap-2.5 min-w-0") do
            icon(entity.icon, fallback: Junction::Kind::DEFAULT_ICON,
                 class: "w-[15px] h-[15px] shrink-0 text-muted-foreground")
            EntityLink(entity:, class: "font-mono text-[12.5px] font-medium " \
                                       "text-text-strong truncate min-w-0")
            span(class: "ml-auto pl-3 shrink-0 text-[11px] " \
                        "text-muted-foreground") { entity.type_name }
          end
        end

        # Overflow marker linking to the dependencies tab.
        #
        # Only renders if there are more entities than displayed.
        #
        # @param hidden [Integer] Undisplayed associated entities.
        def more(hidden)
          return unless hidden.positive?

          button(type: "button",
                 data: { action: "click->ruby-ui--tabs#show",
                         value: "dependencies" },
                 class: "mt-3 text-[11.5px] font-medium text-accent-strong " \
                        "hover:underline cursor-pointer") do
            t(".more", count: hidden)
          end
        end

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end
      end
    end
  end
end
