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

          # If it's the default, leave it out of the URL.
          @per_page = per_page if per_page && per_page != Junction::Paginatable::DEFAULT_PER_PAGE

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

        # One chip per tag, each removable on its own. Two tags means both, so
        # a chip holding several values would be claiming otherwise.
        def tag_chips
          @metadata.tags.each do |tag|
            applied_chip(t(".tag_chip", value: tag),
                         t(".tag", value: tag),
                         metadata_path(tags: @metadata.tags - [ tag ]))
          end
        end

        # A label names a key and what it holds, or that it holds nothing.
        def label_chips
          @metadata.labels.each do |key, value|
            applied_chip(t(".label_chip", key:, value:),
                         t(".label", key:),
                         metadata_path(labels: @metadata.labels.except(key)))
          end

          @metadata.unset.each do |key|
            applied_chip(t(".label_chip_unset", key:),
                         t(".label", key:),
                         metadata_path(unset: @metadata.unset - [ key ]))
          end
        end

        # A chip for a filter that's been applied.
        #
        # @param text [String] What the chip reads.
        # @param label [String] What removing it is called, for screen readers.
        # @param remove [String] Where the remove link goes.
        def applied_chip(text, label, remove)
          div(class: "flex items-center") do
            span(class: "#{CHIP} bg-accent text-accent-foreground " \
                        "rounded-r-none pr-2") { text }

            remove_anchor(label, remove)
          end
        end

        # The remove link on an active chip.
        #
        # A link of its own rather than a menu item, so dropping a filter takes
        # one click.
        #
        # @param label [String] Human name for what's being dropped.
        # @param predicate [String] The Ransack predicate.
        def remove_link(label, predicate)
          remove_anchor(label, choose(predicate, nil))
        end

        # @param label [String] Human name for what's being dropped.
        # @param href [String] Page link without the filter.
        def remove_anchor(label, href)
          a(href:, aria_label: t(".remove", label:),
            class: "-ml-1 h-[30px] pr-2 pl-1 flex items-center " \
                   "rounded-r-lg bg-accent text-accent-muted " \
                   "hover:text-accent-foreground") do
            icon("x", class: "w-3.5 h-3.5")
          end
        end

        # The filters not on the bar yet.
        #
        # One pane at a time: the filters themselves, then the values of
        # whichever was chosen. Tags and labels have as many values as the
        # listing has, which is more than belongs in a flat menu.
        def add_menu
          return unless add_menu?

          DropdownMenu(options: { placement: "bottom-start" }) do |dropdown|
            dropdown.trigger do |trigger|
              trigger.button(variant: :ghost,
                             class: "#{CHIP} bg-subtle text-text-tertiary " \
                                    "hover:text-foreground") { t(".add") }
            end

            dropdown.content(class: "w-[360px] p-0",
                             data: menu_data) do |content|
              root_pane(content)
              tags_pane
              labels_pane
            end
          end
        end

        # @return [Boolean] Whether anything is left to add.
        def add_menu?
          (available - shown).any? || offer_tags? || offer_labels?
        end

        # @return [Hash] The menu's controller wiring.
        def menu_data
          {
            controller: "filter-menu",
            filter_menu_chip_value: t(".label_chip", key: "%{key}", value: "%{value}"),
            filter_menu_chip_unset_value: t(".label_chip_unset", key: "%{key}")
          }
        end

        # The filters themselves.
        #
        # @param content [Object] The menu being built.
        def root_pane(content)
          pane("root", class: "py-1") do
            (available - shown).each do |_set, predicate, field|
              content.item(href: path(added: @added + [ predicate ])) do
                plain @entity_class.human_attribute_name(field)
              end
            end

            pane_link("tags", t(".tags")) if offer_tags?
            pane_link("labels", t(".labels")) if offer_labels?
          end
        end

        # A row that swaps the menu for another pane.
        #
        # @param name [String] The pane to open.
        # @param label [String] What the row reads.
        def pane_link(name, label)
          button(type: "button", data: { pane: name, action: "click->filter-menu#open" },
                 class: "w-full flex items-center justify-between gap-2 " \
                        "rounded-sm px-2 py-1.5 text-sm cursor-pointer " \
                        "hover:bg-accent hover:text-accent-foreground") do
            plain label
            icon("chevron-right", class: "w-3.5 h-3.5 opacity-70")
          end
        end

        # Every tag in the listing that is not already filtered on.
        def tags_pane
          return unless offer_tags?

          pane("tags") do
            pane_header(t(".tags"))

            div(class: "max-h-64 overflow-y-auto px-1 py-1") do
              unfiltered_tags.each do |tag|
                a(href: metadata_path(tags: @metadata.tags + [ tag ]),
                  class: "block rounded-sm px-2 py-1.5 text-sm " \
                         "hover:bg-accent hover:text-accent-foreground") { tag }
              end
            end

            pane_note(t(".tags_note"))
          end
        end

        # Label keys beside the values they hold: a filter needs both, so the
        # pane asks for the key first and shows that key's values next to it.
        def labels_pane
          return unless offer_labels?

          pane("labels") do
            pane_header(t(".labels"))

            div(class: "flex") do
              label_keys_column
              label_values_column
            end

            pane_note(t(".labels_note"))
            preview_row
          end
        end

        # One pane of the menu.
        #
        # Only the open one is rendered visible.
        #
        # @param name [String] The pane's name.
        # @param user_attrs [Hash] Additional HTML attributes.
        def pane(name, **user_attrs, &)
          div(data: { pane: name, filter_menu_target: "pane" },
              hidden: name != "root", **user_attrs, &)
        end

        # A pane's title, with the way back to the filters.
        #
        # @param title [String] The pane's title.
        def pane_header(title)
          div(class: "flex items-center gap-2 border-b border-border " \
                     "px-2 py-1.5") do
            button(type: "button", aria_label: t(".back"),
                   data: { action: "click->filter-menu#back" },
                   class: "rounded-sm p-1 text-muted-foreground cursor-pointer " \
                          "hover:bg-subtle hover:text-foreground") do
              icon("chevron-left", class: "w-3.5 h-3.5")
            end

            span(class: "text-[12.5px] font-semibold text-foreground") { title }
          end
        end

        # The line under a pane saying how it behaves.
        #
        # @param text [String] The note.
        def pane_note(text)
          p(class: "border-t border-border px-3 py-2 text-[11px] " \
                   "text-muted-foreground") { text }
        end

        # The keys, of which one is always chosen.
        def label_keys_column
          div(class: "w-[45%] border-r border-border py-1 " \
                     "max-h-64 overflow-y-auto") do
            caption(t(".label_key"))

            unfiltered_label_keys.each_with_index do |key, index|
              button(type: "button",
                     data: { key:, state: (index.zero? ? "active" : "inactive"),
                             filter_menu_target: "key",
                             action: "click->filter-menu#selectKey" },
                     class: "w-full text-left rounded-sm px-2 py-1.5 " \
                            "font-mono text-[12px] cursor-pointer " \
                            "text-text-body hover:bg-subtle " \
                            "data-[state=active]:bg-accent-subtle " \
                            "data-[state=active]:text-accent-foreground") { key }
            end
          end
        end

        # The chosen key's values, and the absence of the key itself.
        def label_values_column
          div(class: "flex-1 py-1 max-h-64 overflow-y-auto") do
            caption(t(".label_value"))

            unfiltered_label_keys.each_with_index do |key, index|
              div(data: { key:, filter_menu_target: "values" },
                  hidden: !index.zero?) do
                @metadata_options.label_values(key).each do |value|
                  label_value_link(key, value)
                end

                label_value_link(key, nil)
              end
            end
          end
        end

        # One value of a label key, or the absence of the key itself.
        #
        # @param key [String] The label key.
        # @param value [String, nil] The value, or nil for "not set".
        def label_value_link(key, value)
          href = if value
            metadata_path(labels: @metadata.labels.merge(key => value))
          else
            metadata_path(unset: @metadata.unset + [ key ])
          end

          a(href:, data: { key:, value: value.to_s,
                           action: "mouseenter->filter-menu#hover " \
                                   "focus->filter-menu#hover" },
            class: "block rounded-sm px-2 py-1.5 text-[12px] " \
                   "text-text-body hover:bg-accent " \
                   "hover:text-accent-foreground") do
            value || t(".label_unset")
          end
        end

        # A column's heading.
        #
        # @param text [String] The heading.
        def caption(text)
          p(class: "px-2 pb-1 text-[10.5px] font-semibold uppercase " \
                   "tracking-[0.08em] text-muted-foreground") { text }
        end

        # What the chip will read once a value is chosen.
        def preview_row
          div(class: "border-t border-border px-3 py-2") do
            span(data: { filter_menu_target: "preview" },
                 class: "#{CHIP} bg-accent text-accent-foreground")
          end
        end

        # @return [Boolean] Whether the listing has tags left to offer.
        def offer_tags?
          @metadata_options&.tags? && unfiltered_tags.any?
        end

        # @return [Boolean] Whether the listing has label keys left to offer.
        def offer_labels?
          @metadata_options&.labels? && unfiltered_label_keys.any?
        end

        # @return [Array<String>] Tags not already filtered on.
        def unfiltered_tags
          @unfiltered_tags ||= @metadata_options.tags - @metadata.tags
        end

        # @return [Array<String>] Label keys not already filtered on, either
        #   by value or by absence.
        def unfiltered_label_keys
          @unfiltered_label_keys ||=
            @metadata_options.label_keys - @metadata.labels.keys - @metadata.unset
        end

        def clear_link
          return if @query_params.blank? && @added.empty? && !@metadata.any?

          a(href: path(query: {}, added: [], metadata: {}),
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
               added: filters, tab: (leaving ? nil : :current))
        end

        # Hidden inputs carrying what the search box is not itself responsible
        # for.
        #
        # @param except [Symbol] The predicate the box owns.
        def carried_fields(except:)
          input(type: "hidden", name: "tab", value: @tab) if carry_tab?(@tab)
          if @per_page
            input(type: "hidden", name: "per_page", value: @per_page)
          end

          if @added.any?
            input(type: "hidden", name: "filters", value: @added.join(","))
          end

          # Searching must not drop the chips beside the box.
          @metadata.tags.each do |tag|
            input(type: "hidden", name: "tags[]", value: tag)
          end
          @metadata.labels.each do |key, value|
            input(type: "hidden", name: "labels[#{key}]", value:)
          end
          @metadata.unset.each do |key|
            input(type: "hidden", name: "labels_unset[]", value: key)
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
        def path(query: @query_params, added: @added, tab: :current,
                 metadata: @metadata.to_params)
          tab = @tab if tab == :current
          args = { q: query.compact_blank.presence,
                   filters: added.uniq.join(",").presence,
                   per_page: @per_page }
          args[:tab] = tab if carry_tab?(tab)

          public_send(:"#{@entity_class.model_name.route_key}_path",
                      **args.compact.merge(metadata))
        end

        # Path with the tag and label filters changed, holding everything else
        # in place.
        #
        # @param tags [Array<String>] Tags to filter on.
        # @param labels [Hash] Label key to value.
        # @param unset [Array<String>] Label keys that must be absent.
        # @return [String] The path.
        def metadata_path(tags: @metadata.tags, labels: @metadata.labels,
                          unset: @metadata.unset)
          path(metadata: Junction::MetadataFilters.new(tags:, labels:, unset:).to_params)
        end
      end
    end
  end
end
