# frozen_string_literal: true

module Components
  class ReferenceField < Base
    def initialize(form, method, label, options: [], help_text: nil, icon: "disc-2", required: false, value: nil, **user_attrs)
      @form = form
      @method = method
      @label = label
      @help_text = help_text
      @required = required
      @value = value
      @options = options
      @placeholder = user_attrs.delete(:placeholder) { "Select a #{label}" }
      @icon = icon
      @errors = @form.object.errors[@method]

      super(**user_attrs)
    end

    def view_template
      div do
        @form.label @method, class: "block text-sm font-medium leading-6 text-gray-900 dark:text-white" do
          plain @label
          span(class: "text-red-500 ml-1") { " *" } if @required
        end

        div(class: "mt-2") do
          render Select do
            SelectInput(value: @value&.id, id: @form.field_id(@method), name: @form.field_name(@method))
            SelectTrigger(class: "h-auto") do
              render SelectValue.new(id: @form.field_id(@method), class: "px-2") do
                @value.present? ? item_content(@value, "valueContent") : empty_content
              end
            end

            SelectContent(outlet_id: @form.field_id(@method)) do
              @options.each do |record|
                render SelectItem.new(value: record.id, selected: @value.present? && @value.id == record.id) do
                  item_content(record)
                end
              end
            end
          end
        end

        p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

        # If there are any validation errors, display them below the field
        if @errors.any?
          div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "#{@method}_errors") do
            @errors.each do |error|
              p { "#{@label} #{error}" }
            end
          end
        end
      end
    end

    private

    def empty_content
      div(class: "flex items-center space-x-4 text-left", data_ruby_ui__select_target: "valueContent") do
        div(class: "h-6 w-6 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
          icon(@icon, class: "h-6 w-6 text-gray-500")
        end

        div do
          div(class: "text-sm font-medium text-gray-900 dark:text-white") { "No #{@label} selected" }
          div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs italic") { @placeholder }
        end
      end
    end

    def item_content(record, target = "itemContent")
      div(class: "flex items-center space-x-4 text-left", data_ruby_ui__select_target: target) do
        if record.image_url.present?
          img(src: record.image_url, alt: "#{record.name} logo", class: "h-6 w-6 rounded-md object-cover flex-shrink-0")
        else
          div(class: "h-6 w-6 rounded-md bg-gray-200 dark:bg-gray-700 flex items-center justify-center flex-shrink-0") do
            icon(@icon, class: "h-6 w-6 text-gray-500")
          end
        end

        div do
          div(class: "text-sm font-medium text-gray-900 dark:text-white") { record.name }
          div(class: "text-sm text-gray-500 dark:text-gray-400 truncate max-w-xs") { record.description }
        end
      end
    end

    def default_attrs
      {
        class: "block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 dark:bg-gray-700 dark:text-white dark:ring-gray-600 dark:focus:ring-blue-500",
        placeholder: "Select a #{@label}",
      }
    end
  end
end
