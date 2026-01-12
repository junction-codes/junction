# frozen_string_literal: true

module Components
  class AnnotationsForm < Base
    def initialize(form:, context:)
      @form = form
      @context = context
    end

    def view_template
      return if annotations.empty?

      render Components::Card.new do |card|
        card.header do |header|
          header.title { "Annotations" }
          header.description do
            plain <<~EOT
              Metadata used to identify this entity within external systems
              (e.g. monitoring, incident management, etc.).
            EOT
          end

          # TODO: Support adding/editing arbitrary annotations.
          card.content(class: "space-y-4") do
            annotations.each_value do |annotation|
              render_field_for(annotation)
            end
          end
        end
      end
    end

    private

    # TODO: Support arbitrary annotations.
    def annotations
      @annotations ||= Junction::PluginRegistry.instance.annotations_for(@context.class)
    end

    def render_field_for(annotation)
      TextField(
        @form,
        annotation[:key],
        "#{annotation[:title]} (#{annotation[:key]})",
        placeholder: annotation[:placeholder]
      )
    end
  end
end
