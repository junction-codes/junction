# frozen_string_literal: true

module Junction
  module Components
    # Base class for all field components.
    #
    # @abstract
    class FieldType < Base
      LABEL_CLASS = "block text-sm font-medium leading-6 text-gray-900 " \
                    "dark:text-white"

      # Initializes a new field component.
      #
      # @param form [ActionView::Helpers::FormBuilder] The form builder.
      # @param method [Symbol] Method name for the field.
      # @param label [String] Optional, human-readable label for the field.
      #   Defaults to the human-readable name of the field attribute. Set to an
      #   empty string ("") to omit the label.
      # @param help_text [String] Optional help text for the field.
      # @param placeholder [String] Optional placeholder text for the field.
      # @param required [Boolean] Whether the field is required.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(form, method, label: nil, help_text: nil, placeholder: nil,
                     required: false, **user_attrs)
        @form = form
        @method = method
        @label = label
        @help_text = help_text
        @placeholder = placeholder
        @required = required

        super(**user_attrs)
      end

      # Returns the label for the field.
      #
      # @return [String] The label for the field.
      def label_text
        return @label unless @label.nil?

        @label = @form.object&.class&.human_attribute_name(@method) || @method.to_s.humanize
      end

      private

      # Returns the entity for the field.
      #
      # @return [ApplicationRecord] The entity for the field.
      def entity
        @form.object
      end

      # Returns the type of the entity for the field.
      #
      # @return [String] The type of the entity for the field.
      def entity_type
        @form.object_name
      end

      # Returns any errors for the field.
      #
      # @return [Array<String>] Errors for the field.
      def errors
        @errors ||= @form.object&.errors&.[](@method) || []
      end

      # Returns whether the form object has been persisted.
      #
      # @return [Boolean] Whether the form object has been persisted.
      def persisted?
        @form.object.persisted?
      end

      # Renders the label for a field component.
      def render_label
        return if label_text.blank?

        @form.label @method, class: LABEL_CLASS do
          plain label_text
          span(class: "text-red-500 ml-1") { " *" } if @required
        end
      end
    end
  end
end
