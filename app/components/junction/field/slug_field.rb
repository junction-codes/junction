# frozen_string_literal: true

module Junction
  module Components
    # Renders a slug/title pair on entity create forms.
    #
    # In auto mode (default): as the user types in the title input, the slug is
    # automatically derived and shown as read-only text.
    #
    # In manual mode: the slug is an editable text input and updates from the
    # title input no longer update the slug.
    #
    # In each mode, a link is provided to switch between them.
    class SlugField < Base
      INPUT_CLASS = "block w-full rounded-md border-0 py-1.5 text-gray-900 " \
                    "shadow-sm ring-1 ring-inset ring-gray-300 " \
                    "placeholder:text-gray-400 focus:ring-2 focus:ring-inset " \
                    "focus:ring-blue-600 sm:text-sm sm:leading-6 " \
                    "dark:bg-gray-700 dark:text-white dark:ring-gray-600 " \
                    "dark:focus:ring-blue-500"

      LABEL_CLASS = "block text-sm font-medium leading-6 text-gray-900 " \
                    "dark:text-white"

      # Initialize a new component.
      #
      # @param form [ActionView::Helpers::FormBuilder] The form builder.
      # @param label [String] The label for the field input.
      # @param help_text [String] Optional help text for the field.
      # @param required [Boolean] Whether the field is required.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(form, label:, help_text: nil, required: false, **user_attrs)
        @form = form
        @label = label
        @help_text = help_text
        @required = required

        super(**user_attrs)
      end

      def view_template
        div(data: {
            controller: "slug-field",
            slug_field_persisted_value: persisted?.to_s
          }, **attrs) do
          title_field_section
          name_field_section
        end
      end

      private

      # Determines if the form object has been persisted.
      #
      # @return [Boolean] Whether or not the form object has been persisted.
      def persisted?
        @persisted ||= @form.object.persisted?
      end

      # Render the title field section.
      def title_field_section
        div do
          @form.label :title, class: LABEL_CLASS do
            plain @label
            span(class: "text-red-500 ml-1") { " *" } if @required
          end

          div(class: "mt-2") do
            @form.text_field :title,
              class: INPUT_CLASS,
              required: @required,
              data: {
                slug_field_target: "titleInput",
                action: "input->slug-field#onTitleInput"
              }
          end

          p(class: "mt-2 text-sm text-gray-500") { @help_text } if @help_text

          if @form.object.errors[:title].any?
            div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "title_errors") do
              @form.object.errors[:title].each { |e| p { "#{@label} #{e}" } }
            end
          end
        end
      end

      # Render the name field section.
      def name_field_section
        div(class: "mt-4") do
          div(class: "flex items-center justify-between") do
            span(class: LABEL_CLASS) { "Identifier" }

            unless persisted?
              div(class: "flex gap-2 text-xs") do
                a(
                  href: "#",
                  class: "hidden text-blue-500 hover:underline",
                  data: {
                    slug_field_target: "autoLink",
                    action: "click->slug-field#enableAutoMode"
                  }
                ) { "Auto" }

                a(
                  href: "#",
                  class: "text-blue-500 hover:underline",
                  data: {
                    slug_field_target: "editLink",
                    action: "click->slug-field#enableEditMode"
                  }
                ) { "Edit" }
              end
            end
          end

          div(class: "mt-2") do
            if persisted?
              Tooltip do |tooltip|
                tooltip.trigger do
                  code(class: "font-mono text-sm text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded px-2 py-1 cursor-default") do
                    plain @form.object.name
                    span(class: "sr-only") { " (cannot be changed after creation)" }
                  end
                end

                tooltip.content { "The identifier cannot be changed after creation." }
              end

              @form.hidden_field :name
            else
              div(data: { slug_field_target: "slugDisplayWrapper" }) do
                code(
                  class: "font-mono text-sm text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 rounded px-2 py-1 inline-block min-w-16",
                  data: { slug_field_target: "slugDisplay" }
                ) { @form.object.name.presence || "auto-generated" }
                @form.hidden_field :name, data: { slug_field_target: "slugInput" }
              end

              div(
                class: "hidden",
                data: { slug_field_target: "slugInputWrapper" }
              ) do
                @form.text_field :name,
                  class: INPUT_CLASS,
                  name: nil,
                  data: {
                    slug_field_target: "slugManualInput",
                    action: "input->slug-field#onManualSlugInput"
                  }
              end
            end
          end

          if @form.object.errors[:name].any?
            div(class: "mt-2 text-sm text-red-600 dark:text-red-400", id: "name_errors") do
              @form.object.errors[:name].each { |e| p { "Identifier #{e}" } }
            end
          end
        end
      end
    end
  end
end
