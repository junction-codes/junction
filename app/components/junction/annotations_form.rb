# frozen_string_literal: true

module Junction
  module Components
    class AnnotationsForm < Base
      def initialize(form:, context:)
        @form = form
        @context = context
      end

      def view_template
        return if annotations.empty?

        Card do |card|
          card.header do |header|
            header.title { t(".title") }
            header.description { t(".description") }
          end

          card.content(class: "space-y-4") do
            annotations.each_value do |annotation|
              render_field_for(annotation)
            end
          end
        end
      end

      private

      # TODO: Support arbitrary annotations.
      def annotations
        @annotations ||= Junction::PluginRegistry.annotations_for(@context.class)
      end

      def render_field_for(annotation)
        Text(
          @form,
          annotation[:key],
          label: "#{annotation[:title]} (#{annotation[:key]})",
          placeholder: annotation[:placeholder]
        )
      end
    end
  end
end
