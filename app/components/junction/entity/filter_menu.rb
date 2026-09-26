# frozen_string_literal: true

module Junction
  module Components
    module Entity
      # The "Add filter" menu above a catalog listing.
      #
      # One pane at a time: the filters themselves, then the values of
      # whichever was chosen. Tags and labels have as many values as the
      # listing has entities, which is more than belongs in a flat menu, so
      # each opens a pane of its own.
      #
      # Choosing a value is a link, like every other filter. The menu only
      # swaps panes and tracks which key is on show.
      class FilterMenu < Base
        include Junction::EntityCopy

        share_translations

        # Initializes the component.
        #
        # @param entity_class [Class] The kind being listed.
        # @param filters [Array<Array>] Filters not on the bar yet, as the
        #   `[option set, predicate, field]` rows `EntityFilters` holds.
        # @param params [Junction::CatalogFilterParams] The listing's current
        #   parameters, which every link is built from.
        # @param path [Proc] Turns a parameter set into a path.
        # @param metadata_filters [Junction::MetadataFilters] Tag and label
        #   filters in force.
        # @param chip_templates [Array(String, String)] How a label chip reads,
        #   with `%{key}` and `%{value}` left in, so the preview and the chip
        #   it previews are worded in one place.
        # @param metadata_options [Junction::MetadataOptions] Tags and labels
        #   the listing carries.
        def initialize(entity_class:, filters:, params:, path:,
                       metadata_filters:, chip_templates:,
                       metadata_options: nil)
          @entity_class = entity_class
          @filters = filters
          @params = params
          @path = path
          @metadata = metadata_filters
          @metadata_options = metadata_options
          @chip_template, @chip_unset_template = chip_templates

          super()
        end

        def view_template
          return unless any?

          DropdownMenu(options: { placement: "bottom-start" }) do |dropdown|
            dropdown.trigger do |trigger|
              trigger.button(variant: :ghost, class: trigger_classes) { t(".add") }
            end

            dropdown.content(class: "w-[360px] p-0", data: menu_data) do |content|
              root_pane(content)
              tags_pane
              labels_pane
            end
          end
        end

        private

        # Whether or not there are any filters available to add.
        #
        # @return [Boolean] Whether anything is left to add.
        def any?
          @filters.any? || offer_tags? || offer_labels?
        end

        def trigger_classes
          FilterChip::STYLES.fetch(:quiet)
        end

        # Data attributes for the menu's controller wiring.
        #
        # @return [Hash] The menu's controller wiring.
        def menu_data
          {
            controller: "filter-menu",
            filter_menu_chip_value: @chip_template,
            filter_menu_chip_unset_value: @chip_unset_template
          }
        end

        # The filters themselves.
        #
        # @param content [Object] The menu being built.
        def root_pane(content)
          pane("root", class: "py-1") do
            @filters.each do |_set, predicate, field|
              content.item(href: @path.call(@params.adding(predicate))) do
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
          button(type: "button",
                 data: { pane: name, action: "click->filter-menu#open" },
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

        # One pane of the menu. Only the open one is rendered visible.
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
                 class: FilterChip::STYLES.fetch(:applied))
          end
        end

        # Path to the current listing with the specified filters included.
        #
        # @param tags [Array<String>] Tags to filter on.
        # @param labels [Hash] Label key to value.
        # @param unset [Array<String>] Label keys that must be absent.
        # @return [String] The path.
        def metadata_path(tags: @metadata.tags, labels: @metadata.labels,
                          unset: @metadata.unset)
          @path.call(@params.with_metadata(tags:, labels:, unset:))
        end

        # Whether or not there are any tag filters available to add.
        #
        # @return [Boolean] Whether the listing has tags left to offer.
        def offer_tags?
          @metadata_options&.tags? && unfiltered_tags.any?
        end

        # Whether or not there are any label filters available to add.
        #
        # @return [Boolean] Whether the listing has label keys left to offer.
        def offer_labels?
          @metadata_options&.labels? && unfiltered_label_keys.any?
        end

        # Tags not already filtered on.
        #
        # @return [Array<String>] Tags not already filtered on.
        def unfiltered_tags
          @unfiltered_tags ||= @metadata_options.tags - @metadata.tags
        end

        # Label keys not already filtered on, either by value or by absence.
        #
        # @return [Array<String>] Label keys not already filtered on, either by
        #   value or by absence.
        def unfiltered_label_keys
          @unfiltered_label_keys ||=
            @metadata_options.label_keys - @metadata.labels.keys - @metadata.unset
        end

        # The model class used for translations.
        #
        # @return [Class] The entity class.
        def copy_model
          @entity_class
        end
      end
    end
  end
end
