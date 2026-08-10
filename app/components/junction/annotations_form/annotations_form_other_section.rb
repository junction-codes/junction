# frozen_string_literal: true

module Junction
  module Components
    module AnnotationsForm
      # Renders the other annotations section of an annotations form.
      class AnnotationsFormOtherSection < Base
        # Initializes a new component.
        #
        # @param form [ActionView::Helpers::FormBuilder] Form builder.
        # @param context [ApplicationRecord] The entity to render the form for.
        def initialize(form:, context:)
          @form = form
          @context = context
        end

        def view_template
          section(
            class: "space-y-4",
            data: { controller: "annotations-form" }
          ) do
            h4(class: "text-sm font-semibold text-gray-900 dark:text-gray-100") do
              t(".other")
            end

            p(class: "text-sm text-gray-500 dark:text-gray-400") do
              t(".other_help")
            end

            div(data: { annotations_form_target: "list" }, class: "space-y-4") do
              @context.other_annotation_rows.each do |row|
                div(class: "grid grid-cols-1 gap-4 md:grid-cols-2 other-annotation-row") do
                  AnnotationsFormOtherRow(
                    key_name: "#{@form.object_name}[other_annotations][][key]",
                    value_name: "#{@form.object_name}[other_annotations][][value]",
                    key_value: row[:key],
                    value_value: row[:value]
                  )
                end
              end
            end

            template(data: { annotations_form_target: "rowTemplate" }) do
              div(class: "grid grid-cols-1 gap-4 md:grid-cols-2 other-annotation-row") do
                AnnotationsFormOtherRow(
                  key_name: "#{@form.object_name}[other_annotations][][key]",
                  value_name: "#{@form.object_name}[other_annotations][][value]"
                )
              end
            end

            Button(
              type: "button",
              variant: :secondary,
              data: { action: "click->annotations-form#add" }
            ) do
              icon("plus", class: "w-4 h-4 mr-2")
              plain t(".add_row")
            end
          end
        end

        private

        def t(key, options = {})
          return super(key, **options) unless key[0] == "."

          I18n.t(key, **options.merge(scope: "junction.components.annotations_form"))
        end
      end
    end
  end
end
