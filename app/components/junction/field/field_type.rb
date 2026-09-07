# frozen_string_literal: true

module Junction
  module Components
    module Field
      # Base class for all field components.
      #
      # @abstract
      class FieldType < Base
        LABEL_CLASSES = %w[
          block
          text-sm
          font-medium
          leading-6
          text-gray-900
          dark:text-white
        ].freeze

        attr_reader :help_text, :placeholder

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
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(form, method, label: nil, help_text: nil,
                       placeholder: nil, required: false, **user_attrs)
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
          @errors ||= field_errors
        end

        # Gather errors for a field, handling aliases.
        #
        # When the form binds an alias (e.g. +type+ for +domain_type+),
        # validations attach to the underlying attribute. We check the model's
        # +attribute_aliases+ to see if this field has been aliased.
        #
        # @return [Array<String>] Errors for the field.
        def field_errors
          object_errors = @form.object&.errors
          return [] unless object_errors

          messages = object_errors[@method]
          return messages if messages.present?

          object_class = @form.object.class
          if object_class.respond_to?(:attribute_aliases)
            aliased_column = object_class.attribute_aliases[@method.to_s]
            return object_errors[aliased_column] if aliased_column.present?
          end

          []
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

          @form.label @method, class: LABEL_CLASSES do
            plain label_text
            span(class: "text-red-500 ml-1") { " *" } if @required
          end
        end

        # Labels a field made of several inputs.
        #
        # A `for` attribute can only point at one input, so a composite field
        # labels itself as a group. The container carries `role="group"` and
        # `aria-labelledby` naming this element.
        def render_group_label
          return if label_text.blank?

          span(id: label_id, class: LABEL_CLASSES) do
            plain label_text
            span(class: "text-red-500 ml-1") { " *" } if @required
          end
        end

        # Id of the element naming a composite field.
        #
        # @return [String] The id.
        def label_id
          "#{entity_type}_#{@method}_label"
        end

        # Id of the input a plain label points at.
        #
        # @return [String] The id.
        def input_id
          "#{entity_type}_#{@method}"
        end

        # Renders the field's validation errors, if it has any.
        #
        # A field that leaves this out re-renders after a failed save with no
        # sign of what went wrong, so saving looks like it did nothing.
        def render_errors
          return if errors.empty?

          div(class: "mt-2 text-sm text-red-600 dark:text-red-400",
              id: "#{@method}_errors") do
            errors.each { |error| p { "#{label_text} #{error}" } }
          end
        end
      end
    end
  end
end
