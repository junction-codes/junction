# frozen_string_literal: true

module Junction
  # Shared annotation parameter permitting for annotated entity controllers.
  module HasAnnotations
    extend ActiveSupport::Concern

    private

    # Expected parameter for annotated entities.
    #
    # @return [Array<Hash>] Expected parameters.
    def annotation_param_entries
      [ annotations: {}, other_annotations: [ %i[key value] ] ]
    end

    # Post-permit hook for annotation params on entity attributes.
    #
    # This is a no-op by default, but can be overridden for controllers that
    # have special sanitization requirements.
    #
    # @param attrs [Hash] Permitted parameters hash.
    # @return [Hash] Sanitized parameters hash.
    def sanitize_annotations(attrs)
      attrs
    end

    # Permits entity params including annotation entries.
    #
    # @param scope [Symbol] Top-level params key.
    # @param keys [Array] Additional permitted keys.
    # @yield [Hash] Optional block for further sanitization.
    # @return [Hash] Permitted and sanitized parameters.
    def permit_annotated_params(scope, *keys, &block)
      attrs = sanitize_annotations(
        params.expect(scope => [ *keys, *annotation_param_entries ])
      )
      block ? yield(attrs) : attrs
    end
  end
end
