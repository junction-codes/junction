# frozen_string_literal: true

module Junction
  module Views
    module Entities
      # Detail page for a catalog entity.
      #
      # The header, the tab strip and the overview are the same for every kind.
      # What differs is which related entities the meta row names, what the
      # header offers beside Edit, which tabs sit between Dependencies and
      # Annotations, and what the overview adds below its cards, each a hook
      # that a kind view overrides.
      class Show < Views::Base
        include PluginDispatchHelper
        include Junction::EntityCopy

        share_translations

        attr_reader :breadcrumbs

        # Initializes the view.
        #
        # @param entity [Junction::Entity] The entity being shown.
        # @param can_edit [Boolean] Whether the user may edit it.
        # @param can_destroy [Boolean] Whether the user may delete it.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param tab [String] Optional tab to start open.
        # @param options [Hash] Extra arguments from the controller's
        #   `show_options`.
        def initialize(entity:, can_edit:, can_destroy:, breadcrumbs: [],
                       tab: nil, **options)
          @entity = entity
          @can_edit = can_edit
          @can_destroy = can_destroy
          @breadcrumbs = breadcrumbs
          @tab = tab
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-6 space-y-7") do
              entity_header
              entity_tabs
            end
          end
        end

        private

        # @return [Class] The entity class.
        def copy_model
          @entity.class
        end

        def entity_header
          header(class: "flex flex-wrap items-start justify-between " \
                        "gap-x-6 gap-y-4") do
            div(class: "flex items-start gap-4 min-w-0") do
              KindChip(entity: @entity, size: :lg)

              div(class: "min-w-0") do
                title_row
                p(class: "mt-1.5 font-mono text-[12.5px] text-muted-foreground " \
                         "break-all") { @entity.entity_ref }
                description
                meta
              end
            end

            div(class: "flex items-center gap-2 shrink-0") do
              header_actions
              more_menu
            end
          end
        end

        def title_row
          div(class: "flex flex-wrap items-center gap-x-3 gap-y-1.5") do
            h1(class: "text-[28px] leading-tight font-bold tracking-tight " \
                      "text-foreground") { @entity.title }
            LifecyclePill(lifecycle: @entity.lifecycle)
            type_badge
          end
        end

        def type_badge
          return if @entity.type.blank?

          span(class: "inline-flex items-center rounded-full bg-subtle px-2 " \
                      "py-0.5 text-[11.5px] font-medium text-text-body") do
            @entity.type_name
          end
        end

        def description
          return if summary.blank?

          p(class: "mt-3 max-w-3xl text-[14px] text-text-tertiary") { summary }
        end

        # The line under the slug.
        #
        # @return [String, nil] The text.
        def summary
          @entity.description
        end

        # The line of related entities and freshness under the description.
        def meta
          div(class: "mt-6 flex flex-wrap items-center gap-x-6 gap-y-2 " \
                     "text-[12.5px] text-text-body") do
            owner_item if @entity.class.ownable?
            related_items
            updated_item
          end
        end

        # The owner, with the owner's own chip standing in for an icon.
        def owner_item
          owner = @entity.owner

          span(class: "inline-flex items-center gap-1.5 min-w-0") do
            KindChip(entity: owner, size: :xs)
            span(class: "sr-only") do
              "#{@entity.class.human_attribute_name(:owner_id)}: "
            end
            EntityLink(entity: owner, class: "font-medium")
          end
        end

        # Related items in the meta row as defined by the kind's model.
        #
        # Built from the kind's `detail_meta`. Kinds can add additional items
        # that don't fit the same shape as the standard ones by overriding.
        def related_items
          @entity.class.detail_meta.each do |type, field, options|
            case type
            when :relation
              related_item(relation_for(field, options || {}), relation_label(field))
            when :email
              email_item
            end
          end
        end

        # Resolves a related entity for a `:relation` entry in the meta row.
        #
        # @param field [Symbol] The association to follow.
        # @param options [Hash] `through:` names an association to follow
        #   first, as a component reaches its domain through its system.
        # @return [Junction::Entity, nil] The related entity, if there is one.
        def relation_for(field, options)
          source = options[:through] ? @entity.public_send(options[:through]) : @entity

          source&.public_send(field)
        end

        # Label for a relation.
        #
        # @param field [Symbol] The association.
        # @return [String] The label.
        def relation_label(field)
          @entity.class.human_attribute_name(:"#{field}_id")
        end

        # Renders one related entity in the meta row, or nothing if there is
        # none.
        #
        # @param related [Junction::Entity, nil] The related entity.
        # @param label [String] Relationship label.
        def related_item(related, label)
          return if related.nil?

          span(class: "inline-flex items-center gap-1.5 min-w-0") do
            # The kind's icon rather than the type's, since what is being said
            # is which kind of thing this belongs to.
            icon(related.default_icon, fallback: Junction::Kind::DEFAULT_ICON,
                 class: "w-[15px] h-[15px] shrink-0 text-muted-foreground")
            span(class: "sr-only") { "#{label}: " }
            EntityLink(entity: related)
          end
        end

        def email_item
          return if @entity.email.blank?

          span(class: "inline-flex items-center gap-1.5 min-w-0") do
            icon("mail", class: "w-[15px] h-[15px] shrink-0 text-muted-foreground")
            span(class: "sr-only") { "#{@entity.class.human_attribute_name(:email)}: " }
            Link(href: "mailto:#{@entity.email}", variant: :text) { @entity.email }
          end
        end

        def updated_item
          span(class: "inline-flex items-center gap-1.5") do
            icon("clock", class: "w-[15px] h-[15px] shrink-0 text-muted-foreground")
            span(class: "inline-flex items-baseline gap-1") do
              plain t(".updated")
              whitespace
              RelativeTime(time: @entity.updated_at, format: :long)
            end
          end
        end

        # Actions ahead of the menu.
        def header_actions
          repository_link
        end

        # Link to the entity's source code, if set.
        def repository_link
          return if @entity.source_location.blank?

          Link(href: @entity.source_location, variant: :outline,
               target: "_blank", rel: "noopener noreferrer",
               class: "border-border bg-surface shadow-none text-[13.5px] " \
                      "text-text-strong gap-2") do
            icon("external-link", class: "w-4 h-4")
            plain t(".open_repo")
          end
        end

        # The overflow menu beside the header actions.
        def more_menu
          return unless @can_edit

          DropdownMenu(options: { placement: "bottom-end" }) do |menu|
            menu.trigger do |trigger|
              trigger.button(variant: :outline, size: :md, icon: true,
                             aria_label: t(".more_actions"),
                             class: "border-border bg-surface shadow-none " \
                                    "text-muted-foreground") do
                icon("ellipsis", class: "w-4 h-4")
              end
            end

            menu.content do |content|
              content.item(href: junction_edit_catalog_path(@entity)) do
                icon("pencil", class: "w-4 h-4 mr-2")
                plain t(".edit")
              end
            end
          end
        end

        # The tab strip. Kinds add their own triggers and panes by overriding
        # {#tab_triggers} and {#tab_panes}.
        def entity_tabs
          Tabs(default: "overview", open: @tab, variant: :underline,
               param: "tab") do |tabs|
            tabs.list do |list|
              list.trigger(value: "overview") { t(".overview") }
              tab_trigger(list, "dependencies", t(".dependencies"), dependency_count) if dependable?
              tab_triggers(list)
              tab_trigger(list, "annotations", t(".annotations"), annotations.size)

              render_plugin_tab_triggers(@entity, list)
            end

            pane(tabs, "overview") { overview }
            pane(tabs, "dependencies") { dependencies_section } if dependable?
            tab_panes(tabs)
            pane(tabs, "annotations") { annotations_section }

            render_plugin_tab_content(@entity, tabs)
          end
        end

        # Renders a tab trigger with an optional count beside its label.
        #
        # @param list [Object] The tab list being built.
        # @param value [String] The pane it shows.
        # @param label [String] The tab's label.
        # @param count [Integer] How many items are behind the tab.
        def tab_trigger(list, value, label, count = nil)
          list.trigger(value:) do
            plain label
            if count
              whitespace
              TabCount(value: count)
            end
          end
        end

        # Renders a tab pane, spaced below the strip.
        #
        # @param tabs [Object] The tab set being built.
        # @param value [String] The pane.
        def pane(tabs, value, &)
          tabs.content(value:, class: "mt-6", &)
        end

        # Whether this kind may be a relation source or target.
        #
        # The dependency routes are only drawn for kinds the registry marks
        # dependable, so a kind without them would raise rather than render.
        # This view is the fallback for any kind with no `Show` of its own, so
        # it can't assume the routes exist.
        #
        # @return [Boolean]
        def dependable?
          Junction::Kinds.by_scope(@entity.model_name.element)&.dependable? || false
        end

        # Number of dependencies and dependents the current entity has.
        #
        # @return [Integer] Relations in both directions.
        def dependency_count
          @entity.dependency_targets.count + @entity.dependent_sources.count
        end

        # Annotations attached to the current entity.
        #
        # @return [Array<Array(String, Object)>] Annotations, ordered by key.
        def annotations
          @annotations ||= @entity.annotations.to_h.sort_by(&:first)
        end

        # A tab per kind this one is made of.
        #
        # Built from the kind's `detail_tabs`. Kinds can add additional tabs by
        # overriding.
        #
        # @param list [Object] The tab list being built.
        def tab_triggers(list)
          @entity.class.detail_tabs.each do |plural|
            tab_trigger(list, plural.to_s,
                        part_model(plural).model_name.human(count: 2),
                        @entity.public_send(plural).count)
          end
        end

        # @param tabs [Object] The tab set being built.
        def tab_panes(tabs)
          @entity.class.detail_tabs.each do |plural|
            pane(tabs, plural.to_s) { part_frame(plural) }
          end
        end

        # One lazily loaded list of the entities that make this one up.
        #
        # @param plural [Symbol] The kind's plural scope.
        def part_frame(plural)
          scope = @entity.model_name.element

          turbo_frame_tag "#{scope}_#{plural}", loading: :lazy,
                          src: public_send(:"junction_#{plural}_#{scope}_path", @entity) do
            div(class: "p-4") { Skeleton(class: "h-20") }
          end
        end

        # @param plural [Symbol] The kind's plural scope.
        # @return [Class] The model behind that kind.
        def part_model(plural)
          Junction::Kinds.by_scope(plural.to_s.singularize).model
        end

        def overview
          div(data: { controller: "overflow-title" },
              class: "grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_22rem] " \
                     "gap-6 items-start") do
            div(class: "space-y-6 min-w-0") do
              stat_cards_grid
              plugin_cards
              EntityTagsCard(entity: @entity, edit_path:)
              EntityDependenciesCard(entity: @entity) if dependable?
            end

            div(class: "space-y-6 min-w-0") do
              EntityLinksCard(entity: @entity)
              EntityOwnershipCard(entity: @entity) if @entity.class.ownable?
            end
          end
        end

        # Edit path for the current entity.
        #
        # @return [String, nil] Where to edit the entity, when the user may.
        def edit_path
          junction_edit_catalog_path(@entity) if @can_edit
        end

        def stat_cards_grid
          div(class: "grid grid-cols-1 sm:grid-cols-2 gap-6 empty:hidden") do
            stat_cards
          end
        end

        # Counts a kind shows on its overview. None by default.
        def stat_cards
        end

        def plugin_cards
          plugin_slots.each do |slot|
            render_plugin_ui_components(context: @entity, slot:)
          end
        end

        # The slots plugins may register for this page..
        #
        # @return [Array<Symbol>] The slots, in render order.
        def plugin_slots
          [ :overview_cards ]
        end

        # Every annotation attached to the current entity.
        #
        # Annotations are used by Junction and plugins rather than people, so
        # they have this tab and no overview.
        def annotations_section
          EntityCard(title: t(".annotations"), action: annotations_edit_action,
                     data: { controller: "overflow-title" }) do
            if annotations.empty?
              p(class: "text-[12px] text-muted-foreground") { t(".no_annotations") }
            else
              EntityAnnotationList(annotations:)
            end
          end
        end

        def annotations_edit_action
          [ t(".annotations_edit"), edit_path ] if edit_path
        end

        def dependencies_section
          Tabs(default: "dependencies") do |tabs|
            tabs.list do |list|
              list.trigger(value: "dependencies") { t(".dependencies") }
              list.trigger(value: "dependents") { t(".dependents") }
              list.trigger(value: "graph") { t(".graph") }
            end

            tabs.content(value: "dependencies") do
              turbo_frame_tag "dependencies", src: junction_dependencies_path(@entity), loading: :lazy do
                div(class: "p-4") { Skeleton(class: "h-20") }
              end
            end

            tabs.content(value: "dependents") do
              turbo_frame_tag "dependents", src: junction_dependents_path(@entity), loading: :lazy do
                div(class: "p-4") { Skeleton(class: "h-20") }
              end
            end

            tabs.content(value: "graph") { dependency_graph }
          end
        end

        def dependency_graph
          div(class: "rounded-xl border border-border bg-surface overflow-hidden p-5") do
            div(data_controller: "graph",
                data_graph_url_value: junction_dependency_graph_path(@entity)) do
              div(data_graph_target: "container", class: "w-full h-60")
            end
          end
        end
      end
    end
  end
end
