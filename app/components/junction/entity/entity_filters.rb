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

        CHIP = "inline-flex items-center gap-1.5 h-[30px] px-3 rounded-lg " \
               "text-[12.5px] font-medium whitespace-nowrap"

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
        # @param options [Hash] Option sets keyed by name, as supplied by the
        #   controller's `index_options`. Anything not in {FILTERS} is ignored.
        def initialize(entity_class:, query:, tabs: nil, tab: nil,
                       query_params: {}, added: [], **options)
          @entity_class = entity_class
          @query = query
          @tabs = tabs
          @tab = tab
          @query_params = query_params.to_h.symbolize_keys
          @added = Array(added).map(&:to_s)
          @options = options

          super()
        end

        def view_template
          div(class: "flex flex-wrap items-center gap-2") do
            search_box
            shown.each { |filter| chip(*filter) }
            add_menu
            clear_link
          end
        end

        private

        # The free-text search filter.
        def search_box
          attribute = @entity_class.search_attribute

          form(action: path, method: :get, class: "relative") do
            carried_fields(except: attribute)

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

          div(class: "flex items-center") do
            menu(label, predicate, pairs(set), value)
            remove_link(label, predicate) if value
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
                             class: chip_classes(value.present?)) do
                plain "#{label}: #{value_label(options, value)}"
                icon("chevron-down", class: "w-3 h-3 opacity-70") if value.nil?
              end
            end

            dropdown.content(class: "max-h-80 overflow-y-auto") do |content|
              content.item(href: choose(predicate, nil)) { plain t(".any") }
              content.separator

              options.each do |option_label, option_value|
                content.item(href: choose(predicate, option_value)) do
                  plain option_label
                end
              end
            end
          end
        end

        # The filters not on the bar yet.
        def add_menu
          remaining = available - shown
          return if remaining.empty?

          DropdownMenu(options: { placement: "bottom-start" }) do |dropdown|
            dropdown.trigger do |trigger|
              trigger.button(variant: :ghost,
                             class: "#{CHIP} bg-subtle text-text-tertiary " \
                                    "hover:text-foreground") { t(".add") }
            end

            dropdown.content do |content|
              remaining.each do |_set, predicate, field|
                content.item(href: path(added: @added + [ predicate ])) do
                  plain @entity_class.human_attribute_name(field)
                end
              end
            end
          end
        end

        # The `x` on an active chip.
        #
        # Rendered as a separate link rather than a menu item so dropping a
        # filter takes one click.
        #
        # @param label [String] Human name for the field.
        # @param predicate [String] The Ransack predicate.
        def remove_link(label, predicate)
          a(href: choose(predicate, nil),
            aria_label: t(".remove", label:),
            class: "-ml-1 h-[30px] pr-2 pl-1 flex items-center rounded-r-lg " \
                   "bg-accent text-accent-muted hover:text-accent-foreground") do
            icon("x", class: "w-3.5 h-3.5")
          end
        end

        def clear_link
          return if @query_params.blank? && @added.empty?

          a(href: path(query: {}, added: []),
            class: "#{CHIP} bg-subtle text-text-tertiary " \
                   "hover:text-foreground") { t(".clear") }
        end

        # @param active [Boolean] Whether the chip carries a value.
        # @return [String] The classes.
        def chip_classes(active)
          if active
            return "#{CHIP} bg-accent text-accent-foreground rounded-r-none pr-2"
          end

          "#{CHIP} bg-surface border border-border text-text-body " \
            "hover:bg-subtle"
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

        # Path with one filter set to a value, or cleared when it is nil.
        #
        # Choosing a value for the filter the tab stands for leaves the tab. The
        # tab forces its own value, so staying would be asking for two different
        # ones at once.
        #
        # @param predicate [String] The Ransack predicate.
        # @param value [Object, nil] The value, or nil to clear it.
        # @return [String] The path.
        def choose(predicate, value)
          leaving = implied&.first == predicate
          filters = value.nil? ? @added - [ predicate ] : @added

          path(query: @query_params.merge(predicate.to_sym => value),
               added: filters, tab: (nil if leaving))
        end

        # Hidden inputs carrying what the search box is not itself responsible
        # for.
        #
        # @param except [Symbol] The predicate the box owns.
        def carried_fields(except:)
          input(type: "hidden", name: "tab", value: @tab) if carry_tab?(@tab)
          if @added.any?
            input(type: "hidden", name: "filters", value: @added.join(","))
          end

          @query_params.except(except).each do |key, value|
            next if value.blank?

            input(type: "hidden", name: "q[#{key}]", value:)
          end
        end

        # @param tab [String, nil] The tab.
        # @return [Boolean] Whether it belongs in the URL.
        def carry_tab?(tab)
          tab.present? && tab != Junction::CatalogTabs::DEFAULT
        end

        # @return [Class] The entity class.
        def copy_model
          @entity_class
        end

        # The listing's path, holding the bar and the tab in place.
        #
        # @param query [Hash] Filter values.
        # @param added [Array<String>] Predicates on the bar without a value.
        # @param tab [String] The tab, defaulting to the current one.
        # @return [String] The path.
        def path(query: @query_params, added: @added, tab: :current)
          tab = @tab if tab == :current
          args = { q: query.compact_blank.presence,
                   filters: added.uniq.join(",").presence }
          args[:tab] = tab if carry_tab?(tab)

          public_send(:"#{@entity_class.model_name.route_key}_path",
                      **args.compact)
        end
      end
    end
  end
end
