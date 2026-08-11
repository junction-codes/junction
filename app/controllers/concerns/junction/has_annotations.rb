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
  end
end
