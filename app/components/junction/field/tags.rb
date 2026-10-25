# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Form controls for managing the tags on an entity.
      #
      # Tags are free-form and lowercase. Each committed tag is a chip backed by
      # a hidden input, so the form submits a list rather than a string to be
      # split.
      class Tags < FieldType
        INPUT_CLASSES = <<~CSS
          flex-1 border-0 bg-transparent p-0 text-sm text-foreground
          placeholder:text-text-tertiary focus:ring-0
        CSS

        # The chips and their input share one box, which takes the focus ring
        # the fields beside it take.
        BOX_CLASSES = <<~CSS
          mt-2 flex flex-wrap items-center gap-2 rounded-lg border
          border-border bg-surface px-3 py-2 focus-within:border-ring
          focus-within:ring-2 focus-within:ring-ring
        CSS

        def view_template
          div(id: "#{@method.to_s.dasherize}-field",
              data: {
                controller: "tags-field",
                tags_field_remove_label_value: t(".remove", tag: "%{tag}")
              }) do
            render_label

            div(class: BOX_CLASSES) do
              # Marks the field as submitted, so removing every tag is saved
              # rather than read as "the form did not carry tags". The blank
              # value is discarded when the tags are normalized.
              input(type: "hidden", name: field_name, value: "")

              div(data: { tags_field_target: "list" },
                  class: "contents") { entity.tags.each { |tag| chip(tag) } }

              template(data: { tags_field_target: "chipTemplate" }) { chip }

              input(
                type: "text",
                id: input_id,
                placeholder: t(".placeholder"),
                autocomplete: "off",
                data: {
                  tags_field_target: "input",
                  action: "keydown->tags-field#commit " \
                          "paste->tags-field#paste " \
                          "blur->tags-field#commitPending"
                },
                class: INPUT_CLASSES
              )
            end

            p(class: HELP_CLASSES) { @help_text } if @help_text

            render_errors
          end
        end

        private

        # HTML name for a tag, repeated once per chip.
        #
        # @return [String] The name.
        def field_name
          "#{entity_type}[#{@method}][]"
        end

        # Renders one tag chip, or the blank one the controller clones.
        #
        # @param tag [String] The tag.
        def chip(tag = nil)
          span(
            data: { tags_field_target: "chip" },
            class: "inline-flex items-center gap-1 rounded-md bg-subtle " \
                   "px-2 py-1 text-xs font-medium text-text-body"
          ) do
            input(type: "hidden", name: field_name, value: tag)
            span(data: { tag_label: "" }) { tag }

            button(
              type: "button",
              aria: { label: t(".remove", tag: tag.to_s) },
              data: { action: "click->tags-field#remove" },
              class: "cursor-pointer text-text-tertiary hover:text-foreground"
            ) { icon("x", class: "w-3 h-3") }
          end
        end
      end
    end
  end
end
