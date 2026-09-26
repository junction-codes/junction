# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # The filter row above a catalog listing.
      #
      # Every catalog kind filters the same way, so the only thing that varies
      # is which option sets the controller had to offer, and this needs no
      # per-kind configuration.
      #
      # The bar holds the filters that are doing something. The rest wait in the
      # add filter menu rather than sitting on the bar unset.
      #
      # Chips are links, not a form. A filtered view is a place, and it has to
      # survive being pasted into a ticket. Which filters are on the bar rides
      # in the URL alongside their values, for the same reason.
      #
      # Kinds subclass this so their labels resolve in their own translation
      # scope; the rendering all lives here.
      class EntityFilters < Base
        include Junction::EntityCopy

        share_translations

        # Option sets that can become a chip, in render order, as
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
        # @param tabs [Junction::CatalogTabs] The tabs, which know what filter
        #   each one applies.
        # @param tab [String] The tab currently being viewed.
        # @param query_params [Hash] Filters already applied.
        # @param added [Array<String>] Predicates the viewer put on the bar
        #   without choosing a value yet.
        # @param per_page [Integer] Number of results per page, if set.
        # @param options [Hash] Option sets keyed by name, as supplied by the
        #   controller's `index_options`. Anything not in {FILTERS} is ignored.
        # @param metadata_filters [Junction::MetadataFilters] Any tag or label
        #   filters in use.
        # @param metadata_options [Junction::MetadataOptions] Tags and labels
        #   the listing carries.
        def initialize(entity_class:, query:, tabs: nil, tab: nil,
                       query_params: {}, added: [], per_page: nil,
                       metadata_filters: nil, metadata_options: nil, **options)
          @entity_class = entity_class
          @query = query
          @tabs = tabs
          @tab = tab
          @query_params = query_params.to_h.symbolize_keys
          @metadata = metadata_filters || Junction::MetadataFilters.new
          @metadata_options = metadata_options
          @added = Array(added).map(&:to_s)
          @options = options
          @params = Junction::CatalogFilterParams.new(
            query: @query_params, added: @added, per_page:, tab:,
            metadata: @metadata
          )

          super()
        end

        def view_template
          div(class: "flex flex-wrap items-center gap-2") do
            search_box
            shown.each { |filter| chip(*filter) }
            tag_chips
            label_chips
            add_menu
            clear_link
          end
        end

        private

        # The free-text search filter.
        def search_box
          attribute = @entity_class.search_attribute

          # A GET form replaces the action's query string with its own
          # fields, so the action is the bare listing and the state is in the
          # hidden fields below.
          form(action: listing_path, method: :get, class: "relative") do
            hidden_fields(except: attribute)

            span(class: "absolute left-3 top-1/2 -translate-y-1/2 " \
                        "text-muted-foreground pointer-events-none") do
              icon("search", class: "w-4 h-4")
            end

            input(type: "search", name: "q[#{attribute}]",
                  value: @query.public_send(attribute),
                  placeholder: t(".placeholder.#{attribute}"),
                  aria_label: t(".search"), autocomplete: "off",
                  class: "w-[360px] max-w-full h-9 pl-9 pr-3 rounded-lg " \
                         "border border-border bg-surface text-[13px] " \
                         "text-foreground placeholder:text-muted-foreground " \
                         "focus:outline-none focus:ring-1 focus:ring-ring")
          end
        end

        # One filter, as a menu of its values.
        #
        # @param set [Symbol] Name of the option set.
        # @param predicate [String] The Ransack predicate.
        # @param field [Symbol] Field the label is taken from.
        def chip(set, predicate, field)
          label = @entity_class.human_attribute_name(field)
          value = value_for(predicate)

          FilterChip(remove: (chosen(predicate, nil) if value),
                     remove_label: t(".remove", label:)) do
            menu(label, predicate, pairs(set), value)
          end
        end

        # @param label [String] Human name for the field.
        # @param predicate [String] The Ransack predicate.
        # @param options [Array<Array(String, Object)>] Values to choose from.
        # @param value [Object, nil] The value in force, if any.
        def menu(label, predicate, options, value)
          DropdownMenu(options: { placement: "bottom-start" }) do |dropdown|
            dropdown.trigger do |trigger|
              trigger.button(variant: :ghost,
                             class: FilterChip::STYLES.fetch(
                               value.present? ? :applied : :waiting
                             )) do
                plain "#{label}: #{value_label(options, value)}"
                icon("chevron-down", class: "w-3 h-3 opacity-70") if value.nil?
              end
            end

            dropdown.content(class: "max-h-80 overflow-y-auto") do |content|
              content.item(href: chosen(predicate, nil)) { plain t(".any") }
              content.separator

              options.each do |option_label, option_value|
                content.item(href: chosen(predicate, option_value)) do
                  plain option_label
                end
              end
            end
          end
        end

        # One chip per tag, each removable on its own. Two tags means both, so
        # a chip holding several values would be claiming otherwise.
        def tag_chips
          @metadata.tags.each do |tag|
            FilterChip(text: t(".tag_chip", value: tag),
                       remove: metadata_path(tags: @metadata.tags - [ tag ]),
                       remove_label: t(".remove", label: t(".tag", value: tag)))
          end
        end

        # A label names a key and what it holds, or that it holds nothing.
        def label_chips
          @metadata.labels.each do |key, value|
            FilterChip(text: t(".label_chip", key:, value:),
                       remove: metadata_path(labels: @metadata.labels.except(key)),
                       remove_label: t(".remove", label: t(".label", key:)))
          end

          @metadata.unset.each do |key|
            FilterChip(text: t(".label_chip_unset", key:),
                       remove: metadata_path(unset: @metadata.unset - [ key ]),
                       remove_label: t(".remove", label: t(".label", key:)))
          end
        end

        # The menu of filters not on the bar yet.
        def add_menu
          FilterMenu(entity_class: @entity_class, params: @params,
                     filters: available - shown,
                     path: method(:filter_path),
                     metadata_filters: @metadata,
                     metadata_options: @metadata_options,
                     chip_templates: chip_templates)
        end

        # How a label chip reads, with the interpolations left in for the
        # menu's preview to fill.
        #
        # @return [Array(String, String)] Set and unset wordings.
        def chip_templates
          [ t(".label_chip", key: "%{key}", value: "%{value}"),
            t(".label_chip_unset", key: "%{key}") ]
        end

        def clear_link
          return unless @params.any?

          a(href: filter_path(@params.cleared),
            class: FilterChip::STYLES.fetch(:quiet)) { t(".clear") }
        end

        # Filters available for the entity.
        #
        # @return [Array<Array>] The {FILTERS} rows.
        def available
          @available ||= FILTERS.select { |set, _, _| @options[set].present? }
        end

        # Active filters to render.
        #
        # @return [Array<Array>] The {FILTERS} rows, in render order.
        def shown
          @shown ||= available.select do |_set, predicate, _field|
            value_for(predicate).present? || @added.include?(predicate)
          end
        end

        # The value a predicate is filtering on.
        #
        # @param predicate [String] The Ransack predicate.
        # @return [Object, nil] The value.
        def value_for(predicate)
          return implied.last if implied&.first == predicate

          @query.public_send(predicate).presence
        end

        # @return [Array(String, Object), nil] The filter the tab stands for.
        def implied
          return @implied if defined?(@implied)

          @implied = @tabs&.implied_filter(@tab.to_s)
        end

        # How a chip names its value.
        #
        # `:viewer` has no option behind it. The `mine` tab matches the
        # viewer's groups as well as the viewer, which the owner list cannot
        # express.
        #
        # @param options [Array<Array(String, Object)>] Values to choose from.
        # @param value [Object, nil] The value in force, if any.
        # @return [String] The label.
        def value_label(options, value)
          return t(".any") if value.nil?
          return t(".viewer") if value == :viewer

          options.find { |_, option| option.to_s == value.to_s }&.first || value
        end

        # Option pairs for an option set.
        #
        # @param set [Symbol] Name of the option set.
        # @return [Array<Array(String, Object)>] The pairs.
        def pairs(set)
          options = @options[set]
          return [] if options.blank?
          return options.map { |entity| [ entity.title, entity.id ] } if
            ENTITY_FILTERS.include?(set)

          options
        end

        # @return [Class] The entity class.
        def copy_model
          @entity_class
        end

        # The path with one filter set to a value, or cleared when nil.
        #
        # @param predicate [String] The Ransack predicate.
        # @param value [Object, nil] The value.
        # @return [String] The path.
        def chosen(predicate, value)
          filter_path(@params.choose(predicate, value, implied: implied&.first))
        end

        # The path with the tag and label filters changed.
        #
        # @param tags [Array<String>] Tags to filter on.
        # @param labels [Hash] Label key to value.
        # @param unset [Array<String>] Label keys that must be absent.
        # @return [String] The path.
        def metadata_path(tags: @metadata.tags, labels: @metadata.labels,
                          unset: @metadata.unset)
          filter_path(@params.with_metadata(tags:, labels:, unset:))
        end

        # Hidden inputs carrying what the search box is not responsible for.
        #
        # @param except [Symbol] The predicate the box owns.
        def hidden_fields(except:)
          @params.to_fields(except:).each do |name, value|
            input(type: "hidden", name:, value:)
          end
        end

        # The path to the listing with no filters applied.
        #
        # @return [String] The listing's path, with nothing on it.
        def listing_path
          public_send(:"#{@entity_class.model_name.route_key}_path")
        end

        # The listing's path for a set of parameters.
        #
        # @param params [Junction::CatalogFilterParams] The parameters.
        # @return [String] The path.
        def filter_path(params)
          public_send(:"#{@entity_class.model_name.route_key}_path",
                      **params.to_h)
        end
      end
    end
  end
end
