# frozen_string_literal: true

module Junction
  module Views
    module Entities
      # Listing for a catalog kind.
      #
      # The columns come from the kind's `index_columns` descriptor and the
      # filters from whichever option sets the controller supplied, so this
      # serves every kind without knowing about any of them.
      #
      # Kinds subclass this so their headings resolve in their own translation
      # scope, and point {#filters_component} at their own filters class.
      class Index < Views::Base
        include Junction::EntityCopy

        share_translations

        # Column widths, as a hint to the auto table layout.
        COLUMN_WIDTHS = { entity: "w-[340px]" }.freeze

        # The width the name column is given, and the narrowest the rest
        # may be drawn before the listing scrolls instead of squeezing. Kept as
        # numbers as well as the class because Tailwind cannot read a class
        # name that was assembled at runtime.
        NAME_WIDTH = 340
        MIN_COLUMN_WIDTH = 120

        attr_reader :added_filters, :breadcrumbs, :can_create, :entities, :pagy,
                    :query, :query_params, :tab, :tabs

        # Initializes the view.
        #
        # @param entities [ActiveRecord::Relation] The records on this page.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param tabs [Junction::CatalogTabs] The tabs this kind offers.
        # @param tab [String] The tab being viewed.
        # @param added_filters [Array<String>] Ransack predicates the viewer
        #   put on the filter bar without choosing a value yet.
        # @param can_create [Boolean] Whether the user may create this kind.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        # @param options [Hash] Option sets from the controller's
        #   `index_options`, forwarded to the filters.
        def initialize(entities:, query:, pagy:, tabs:, tab: nil,
                       added_filters: [], can_create: true, breadcrumbs: [],
                       query_params: {}, **options)
          @entities = entities
          @query = query
          @pagy = pagy
          @tabs = tabs
          @added_filters = added_filters
          @tab = tab || Junction::CatalogTabs::DEFAULT
          @can_create = can_create
          @breadcrumbs = breadcrumbs
          @query_params = query_params
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-6 space-y-6") do
              page_header

              render Junction::Components::Entity::EntityTabs.new(
                entity_class:, tabs:, current: tab, query_params:,
                added_filters:
              )

              render Junction::Components::Entity::EntityFilters.new(
                entity_class:, query:, tabs:, tab:, query_params:,
                added: added_filters, **@options
              )

              div(class: "rounded-xl border border-border bg-surface " \
                         "overflow-hidden") do
                Table(fixed: true, min_width: table_min_width) do |table|
                  table_header(table)
                  table_body(table)
                end

                table_footer
              end
            end
          end
        end

        private

        # The kind being listed.
        #
        # Taken from the records where there are any, and from the view's own
        # name otherwise, so an empty listing still knows what it is showing.
        #
        # @return [Class] The entity class.
        def entity_class
          @entity_class ||= @entities.respond_to?(:klass) ? @entities.klass : infer_entity_class
        end

        # @return [Class] The entity class.
        def copy_model
          entity_class
        end

        def page_header
          div(class: "flex items-start justify-between gap-6") do
            div do
              div(class: "flex items-baseline gap-2.5") do
                h1(class: "text-[28px] font-bold text-foreground") do
                  entity_class.model_name.human(count: 2)
                end

                span(class: "text-[15px] font-medium tabular-nums " \
                            "text-muted-foreground") { tabs.counts["all"].to_s }
              end

              p(class: "mt-1 max-w-[700px] text-sm text-text-tertiary") do
                t(".description")
              end
            end

            if @can_create
              Link(variant: :primary, href: new_path,
                   class: "h-9 shrink-0") do
                icon("plus", class: "w-4 h-4 mr-1.5")
                plain t(".new")
              end
            end
          end
        end

        # Minimum width the table is given.
        #
        # @return [Integer] The width in pixels.
        def table_min_width
          others = entity_class.index_columns.size - 1

          NAME_WIDTH + (others * MIN_COLUMN_WIDTH)
        end

        # The range this page covers and its pagination.
        def table_footer
          div(class: "flex flex-wrap items-center justify-between gap-4 " \
                     "border-t border-border px-4 py-3.5") do
            p(class: "text-[12.5px] text-text-tertiary") { showing }

            PaginationNav(
              pagy: @pagy,
              total: nil,
              page_url: ->(page) { index_path(**page_args, page:) },
              per_page_url: lambda { |per_page|
                index_path(**tab_args, q: @query_params, per_page:)
              }
            )
          end
        end

        # @return [String] Text for the displayed range and total.
        def showing
          return t(".showing_none") if @pagy.count.zero?

          t(".showing", from: @pagy.from, to: @pagy.to, count: @pagy.count,
                        kinds: entity_class.model_name.human(count: @pagy.count).downcase)
        end

        # Query-string arguments that have to survive a page change.
        #
        # @return [Hash] The arguments.
        def page_args
          tab_args.merge(q: @query_params, per_page: @pagy.options[:limit])
        end

        # The tab and the filter bar.
        #
        # @return [Hash] The arguments.
        def tab_args
          args = {}
          args[:tab] = tab unless tab == Junction::CatalogTabs::DEFAULT
          args[:filters] = added_filters.join(",") if added_filters.any?
          args
        end

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                index_path(
                  **tab_args,
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              entity_class.index_columns.each do |type, field|
                row.sortable_head(field: field.to_s, sort_url:,
                                  class: COLUMN_WIDTHS[type],
                                  **sort_attrs(query, field.to_s)) do
                  entity_class.human_attribute_name(field)
                end
              end
            end
          end
        end

        def table_body(table)
          table.body do |body|
            @entities.each do |entity|
              body.row do |row|
                entity_class.index_columns.each do |type, field|
                  row.cell { cell(type, field, entity) }
                end
              end
            end
          end
        end

        # Renders one cell.
        #
        # @param type [Symbol] The column type.
        # @param field [Symbol] The column's field.
        # @param entity [Junction::Entity] The row's entity.
        def cell(type, field, entity)
          case type
          when :entity    then EntityPreview(entity:)
          when :reference then reference_cell(entity, field)
          when :lifecycle then lifecycle_cell(entity)
          when :email     then email_cell(entity)
          when :tags      then TagList(tags: entity.tags)
          when :updated   then updated_cell(entity)
          end
        end

        # When the row last changed.
        #
        # @param entity [Junction::Entity] The row's entity.
        def updated_cell(entity)
          RelativeTime(time: entity.updated_at, format: :long,
                       class: "text-[12px] text-text-tertiary")
        end

        # Renders a link to an associated entity, if there is one.
        #
        # @param entity [Junction::Entity] The row's entity.
        # @param field [Symbol] The foreign key.
        def reference_cell(entity, field)
          associated = entity.public_send(field.to_s.delete_suffix("_id"))
          return if associated.nil?

          render_view_link(associated, class: "ps-0 max-w-full block truncate")
        end

        # @param entity [Junction::Entity] The row's entity.
        def lifecycle_cell(entity)
          Badge(variant: entity.lifecycle&.to_sym) { entity.lifecycle&.capitalize }
        end

        # @param entity [Junction::Entity] The row's entity.
        def email_cell(entity)
          return if entity.email.blank?

          Link(href: "mailto:#{entity.email}",
               class: "ps-0 max-w-full block truncate") { entity.email }
        end

        def index_path(**args)
          public_send(:"#{entity_class.model_name.route_key}_path", **args)
        end

        def new_path
          public_send(:"new_#{entity_class.model_name.singular_route_key}_path")
        end

        # Falls back to the kind named by this view's own namespace.
        #
        # @return [Class] The entity class.
        def infer_entity_class
          Junction::Kinds.by_scope(
            self.class.module_parent_name.demodulize.singularize.underscore
          )&.model || Junction::Entity
        end
      end
    end
  end
end
