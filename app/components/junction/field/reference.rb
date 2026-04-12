# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form field for selecting another entity.
      class Reference < FieldType
        # Initializes a new field component.
        #
        # @param form [ActionView::Helpers::FormBuilder] The form builder.
        # @param method [Symbol] Method name for the field.
        # @param label [String] Optional, human-readable label for the field.
        #   Defaults to the human-readable name of the field attribute. Set to
        #   an empty string ("") to omit the label.
        # @param help_text [String] Optional help text for the field.
        # @param placeholder [String] Optional placeholder text for the field.
        # @param required [Boolean] Whether the field is required.
        # @param options [Array] The options for the field.
        # @param icon [String] Default icon for field options.
        # @param value [ApplicationRecord] Currently selected value for the
        #   field.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(form, method, label: nil, help_text: nil,
                       placeholder: nil, required: false, options: [],
                       icon: "disc-2", value: nil, **user_attrs)
          @value = value
          @options = options
          @icon = icon

          super(form, method, label:, help_text:, placeholder:, required:,
                **user_attrs)
        end

        def view_template
          div do
            render_label

            div(class: "mt-2") do
              Select(**attrs) do |select|
                select.input(value: @value&.id, id: @form.field_id(@method), name: @form.field_name(@method))
                select.trigger(class: "h-auto") do |trigger|
                  trigger.value(id: @form.field_id(@method), class: "px-2") do
                    @value.present? ? item_content(@value, "valueContent") : empty_content
                  end
                end

                select.content(outlet_id: @form.field_id(@method)) do |content|
                  content.item(value: "", selected: @value.blank?) do
                    empty_content("itemContent")
                  end

                  @options.each do |record|
                    content.item(value: record.id, selected: @value.present? && @value.id == record.id) do
                      item_content(record)
                    end
                  end
                end
              end
            end

            p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

            # If there are any validation errors, display them below the field
            if errors.any?
              div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "#{@method}_errors") do
                errors.each do |error|
                  p { "#{label_text} #{error}" }
                end
              end
            end
          end
        end

        private

        def empty_content(target = "valueContent")
          div(class: "flex items-center space-x-4 text-left", data_ruby_ui__select_target: target) do
            div(class: "h-6 w-6 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
              icon(@icon, class: "h-6 w-6 text-gray-500")
            end

            div do
              div(class: "text-sm font-medium text-gray-900 dark:text-white") { t(".blank", label: label_text) }
              div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs italic") { placeholder }
            end
          end
        end

        def item_content(record, target = "itemContent")
          div(class: "flex items-center space-x-4 text-left", data_ruby_ui__select_target: target) do
            if record.image_url.present?
              img(src: record.image_url, alt: t(".logo_alt", title: record.title), class: "h-6 w-6 rounded-md object-cover flex-shrink-0")
            else
              div(class: "h-6 w-6 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
                icon(@icon, class: "h-6 w-6 text-gray-500")
              end
            end

            div do
              div(class: "text-sm font-medium text-gray-900 dark:text-white") { record.title }
              div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { record.description }
            end
          end
        end

        def placeholder
          @placeholder ||= t(".blank", label: label_text || @method.to_s.humanize)
        end
      end
    end
  end
end
