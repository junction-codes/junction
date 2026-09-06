# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # Renders the filter bar above a catalog listing.
      #
      # Every catalog kind filters the same way, so the only thing that varies
      # is which option sets the controller had to offer. A filter is drawn for
      # each one that came back with options, in a fixed order, which is why
      # this needs no per-kind configuration.
      #
      # Kinds subclass this so their labels resolve in their own translation
      # scope; the rendering all lives here.
      class EntityFilters < Base
        include Junction::EntityCopy

        share_translations

        # Option sets that become a filter, in render order, as
        # `[option set, Ransack predicate, field the label comes from]`.
        FILTERS = [
          [ :available_types, "type_eq", :type ],
          [ :available_systems, "system_id_eq", :system_id ],
          [ :available_owners, "owner_id_eq", :owner_id ],
          [ :available_domains, "domain_id_eq", :domain_id ],
          [ :available_parents, "parent_id_eq", :parent_id ],
          [ :available_lifecycles, "lifecycle_eq", :lifecycle ]
        ].freeze

        # Option sets holding entities rather than `[label, value]` pairs.
        ENTITY_FILTERS = %i[
          available_systems available_owners available_domains available_parents
        ].freeze

        # Initializes the component.
        #
        # @param entity_class [Class] The kind being listed.
        # @param query [Ransack::Search] Ransack query object for filtering.
        # @param options [Hash] Option sets keyed by name, as supplied by the
        #   controller's `index_options`. Anything not in {FILTERS} is ignored.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(entity_class:, query:, **options)
          @entity_class = entity_class
          @query = query
          @options = options

          super()
        end

        def view_template
          render Table::FilterBar.new(query: @query, action_url: index_path,
                                      clear_url: index_path) do |bar|
            div(class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
              search_filter(bar)
              FILTERS.each { |set, predicate, field| filter(bar, set, predicate, field) }
            end

            div(class: "flex gap-2") { bar.actions }
          end
        end

        private

        # Renders the free-text filter.
        #
        # @param bar [Table::FilterBar] The filter bar being built.
        def search_filter(bar)
          attribute = @entity_class.search_attribute

          bar.text_filter(
            name: "q[#{attribute}]",
            label: t(".search"),
            placeholder: t(".placeholder.#{attribute}"),
            value: @query.public_send(attribute)
          )
        end

        # Renders one option-set filter, if the controller supplied options.
        #
        # @param bar [Table::FilterBar] The filter bar being built.
        # @param set [Symbol] Name of the option set.
        # @param predicate [String] The Ransack predicate.
        # @param field [Symbol] Field the label is taken from.
        def filter(bar, set, predicate, field)
          options = @options[set]
          return if options.blank?

          label = @entity_class.human_attribute_name(field)
          args = {
            name: "q[#{predicate}]",
            label:,
            selected: @query.public_send(predicate),
            include_blank: true,
            blank_label: t(".all", label: label.pluralize)
          }

          if ENTITY_FILTERS.include?(set)
            bar.entity_filter(entities: options, **args)
          else
            bar.select_filter(options:, **args)
          end
        end

        # @return [Class] The entity class.
        def copy_model
          @entity_class
        end

        # Path the filter form submits to.
        #
        # @return [String] The index path.
        def index_path
          public_send(:"#{@entity_class.model_name.route_key}_path")
        end
      end
    end
  end
end
