# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # The tab strip above a catalog listing.
      #
      # Rendered as links since a tab is a view of the catalog, and like
      # every other filter here it lives in the URL.
      class EntityTabs < Base
        include Junction::EntityCopy

        share_translations

        # Initializes the component.
        #
        # @param entity_class [Class] The kind being listed.
        # @param tabs [Junction::CatalogTabs] The available tabs.
        # @param current [String] The tab being viewed.
        # @param query_params [Hash] Filters to carry across in the query
        #   string.
        # @param added_filters [Array<String>] Predicates on the filter bar
        #   without a value, carried across for the same reason.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(entity_class:, tabs:, current:, query_params: {},
                       added_filters: [], **user_attrs)
          @entity_class = entity_class
          @tabs = tabs
          @current = current
          @query_params = query_params
          @added_filters = Array(added_filters)

          super(**user_attrs)
        end

        def view_template
          nav(aria_label: t(".label"), **attrs) do
            ul(class: "flex items-center gap-8 -mb-px") do
              @tabs.names.each { |name| tab(name) }
            end
          end
        end

        private

        # @param name [String] The tab.
        def tab(name)
          current = name == @current

          li do
            a(href: tab_path(name),
              aria_current: ("page" if current),
              class: tab_classes(current)) do
              plain t(".#{name}")
              count(name)
            end
          end
        end

        # @param name [String] The tab.
        def count(name)
          value = @tabs.counts[name]
          return if value.nil?

          span(class: "ml-2 text-[12.5px] tabular-nums " \
                      "text-muted-foreground") { value.to_s }
        end

        # @param current [Boolean] Whether this is the tab being viewed.
        # @return [String] The classes.
        def tab_classes(current)
          base = "inline-flex items-center pb-2 text-[13.5px] border-b-2"

          if current
            "#{base} font-semibold text-foreground border-accent-muted"
          else
            "#{base} font-medium text-text-tertiary border-transparent " \
              "hover:text-foreground hover:border-border"
          end
        end

        # Path for an individual tab.
        #
        # @param name [String] The tab.
        # @return [String] The path.
        def tab_path(name)
          args = { q: @query_params.presence,
                   filters: @added_filters.join(",").presence }.compact
          args[:tab] = name unless name == Junction::CatalogTabs::DEFAULT

          public_send(:"#{@entity_class.model_name.route_key}_path", **args)
        end

        # @return [Class] The entity class.
        def copy_model
          @entity_class
        end

        def default_attrs
          { class: "border-b border-border" }
        end
      end
    end
  end
end
