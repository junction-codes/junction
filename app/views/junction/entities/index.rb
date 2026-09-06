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

        attr_reader :breadcrumbs, :can_create, :entities, :pagy, :query,
                    :query_params

        # Initializes the view.
        #
        # @param entities [ActiveRecord::Relation] The records on this page.
        # @param query [Ransack::Search] Ransack query object for filtering and
        #   sorting.
        # @param pagy [Pagy] Pagy pagination metadata.
        # @param can_create [Boolean] Whether the user may create this kind.
        # @param breadcrumbs [Array<Hash>] Breadcrumb items from the controller.
        # @param query_params [Hash] Query parameters from the controller.
        # @param options [Hash] Option sets from the controller's
        #   `index_options`, forwarded to the filters.
        def initialize(entities:, query:, pagy:, can_create: true,
                       breadcrumbs: [], query_params: {}, **options)
          @entities = entities
          @query = query
          @pagy = pagy
          @can_create = can_create
          @breadcrumbs = breadcrumbs
          @query_params = query_params
          @options = options
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs:) do
            div(class: "px-6 py-3") do
              page_header

              render Junction::Components::Entity::EntityFilters.new(entity_class:, query:, **@options)

              div(class: "bg-white dark:bg-gray-800 rounded-lg shadow overflow-hidden") do
                Table do |table|
                  table_header(table)
                  table_body(table)
                end
              end

              PaginationNav(
                pagy: @pagy,
                page_url: ->(page) { index_path(q: @query_params, page:, per_page: @pagy.options[:limit]) },
                per_page_url: ->(per_page) { index_path(q: @query_params, per_page:) }
              )
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
          div(class: "flex justify-between items-center mb-6") do
            h2(class: "text-2xl font-semibold text-gray-800 dark:text-white") do
              entity_class.model_name.human(count: 2)
            end

            if @can_create
              Link(variant: :primary, href: new_path) { t(".new") }
            end
          end
        end

        def table_header(table)
          table.header do |header|
            header.row do |row|
              sort_url = ->(field, direction) {
                index_path(
                  q: @query_params.merge(s: "#{field} #{direction}"),
                  per_page: @pagy.options[:limit]
                )
              }

              entity_class.index_columns.each do |_type, field|
                row.sortable_head(field: field.to_s, sort_url:,
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
          when :type      then type_cell(entity)
          when :lifecycle then lifecycle_cell(entity)
          when :email     then email_cell(entity)
          end
        end

        # Renders a link to an associated entity, if there is one.
        #
        # @param entity [Junction::Entity] The row's entity.
        # @param field [Symbol] The foreign key.
        def reference_cell(entity, field)
          associated = entity.public_send(field.to_s.delete_suffix("_id"))
          return if associated.nil?

          render_view_link(associated, class: "ps-0")
        end

        # Renders the catalog type, named from the catalog options where the
        # value is declared and humanized where it is not.
        #
        # @param entity [Junction::Entity] The row's entity.
        def type_cell(entity)
          return if entity.type.blank?

          section = Junction::CatalogOptions.section(entity.catalog_section)
          plain section[entity.type]&.[](:name) || entity.type.humanize
        end

        # @param entity [Junction::Entity] The row's entity.
        def lifecycle_cell(entity)
          Badge(variant: entity.lifecycle&.to_sym) { entity.lifecycle&.capitalize }
        end

        # @param entity [Junction::Entity] The row's entity.
        def email_cell(entity)
          return if entity.email.blank?

          Link(href: "mailto:#{entity.email}", class: "ps-0") { entity.email }
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
