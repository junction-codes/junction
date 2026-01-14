# frozen_string_literal: true

module Junction
  module Components
    # Filter bar component for tables.
    class TableFilterBar < Base
      include Phlex::Rails::Helpers::FormWith

      INPUT_CLASSES = <<~CSS
        w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md
        shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500
        dark:bg-gray-700 dark:text-white
      CSS

      # Initializes a new TableFilterBar component.
      #
      # @param query [Ransack::Search] Ransack query object for filtering.
      # @param action_url [String] URL to submit the filter form to.
      # @param clear_url [String] Optional URL to clear the filters.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(query:, action_url:, clear_url: nil, **user_attrs)
        @query = query
        @action_url = action_url
        @clear_url = clear_url

        super(**user_attrs)
      end

      def view_template(&block)
        div(**attrs) do
          form_with url: @action_url, method: :get, local: true, class: "space-y-4" do |f|
            @form = f
            yield if block
          end
        end
      end

      # Renders a text filter input.
      #
      # @param name [String] The name attribute for the input.
      # @param label [String] The label text for the input.
      # @param placeholder [String] Placeholder text for the input.
      # @param value [String] The current value of the input.
      def text_filter(name:, label:, placeholder: nil, value: nil)
        div do
          filter_label(label, for: name)
          input(
            type: "text",
            name:,
            id: name,
            placeholder:,
            value:,
            autocomplete: "off",
            class: INPUT_CLASSES
          )
        end
      end

      # Renders a select filter input for entity selections.
      #
      # @param name [String] The name attribute for the select.
      # @param label [String] Label text for the select.
      # @param entities [ActiveRecord::Relation] Available entities with name and
      #  id attributes.
      # @param selected [String] Currently selected value.
      # @param include_blank [Boolean] Whether to include a blank option.
      # @param blank_label [String] Optional label for the blank option.
      def entity_filter(name:, label:, entities:, selected: nil,
                        include_blank: true, blank_label: nil)
        options = entities.map { |entity| [ entity.name, entity.id ] }
        select_filter(name:, label:, options:, selected:, include_blank:, blank_label:)
      end

      # Renders a select filter input.
      #
      # @param name [String] The name attribute for the select.
      # @param label [String] Label text for the select.
      # @param options [Array<Array>] Available options as [label, value] pairs.
      # @param selected [String] Currently selected value.
      # @param include_blank [Boolean] Whether to include a blank option.
      # @param blank_label [String] Optional label for the blank option.
      def select_filter(name:, label:, options:, selected: nil,
                        include_blank: true, blank_label: nil)
        div do
          filter_label(label, for: name)
          select(
            name:,
            id: name,
            autocomplete: "off",
            class: INPUT_CLASSES
          ) do
            option(value: "") { blank_label || "All" } if include_blank
            select_filter_options(options, selected:)
          end
        end
      end

      # Renders action buttons for the filter bar.
      #
      # @yield [block] Optional block to render additional actions.
      def actions(&block)
        div(class: "flex gap-2") do
          Button(type: :submit, variant: :primary) { "Search" }
          Link(href: @clear_url, variant: :secondary) { "Clear" } if @clear_url

          yield if block
        end
      end

      private

      def default_attrs
        {
          class: "mb-6 bg-white dark:bg-gray-800 rounded-lg shadow p-4"
        }
      end

      # Renders a label for a filter input.
      #
      # @param text [String] Label text.
      # @param for: [String] ID of the input this label is for.
      def filter_label(text, for:)
        label(for:, class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1") { text }
      end

      # Renders options for a select filter.
      #
      # @param options [Array<Array>] Available options as [label, value] pairs.
      # @param selected [String] Currently selected value.
      def select_filter_options(options, selected: nil)
        options.each do |option|
          label_text, value = option.slice(0, 2)

          option(value:, selected: selected.to_s == value.to_s) { label_text }
        end
      end
    end
  end
end
