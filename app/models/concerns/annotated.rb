# frozen_string_literal: true

# Provides specialized access to the 'annotations' jsonb field.
module Annotated
  extend ActiveSupport::Concern

  included do
    attribute :annotations, :jsonb, default: {}
  end

  # Annotations for the current model.
  #
  # Instead of the returning the raw hash, we use a custom accessor class
  # that provides some convenience methods for working with annotations.
  #
  # @return [AnnotationsAccessor]
  def annotations
    AnnotationsAccessor.new(self, self[:annotations])
  end

  # Set the annotations for the current model.
  #
  # The value may be our custom accessor class, but the database expects a hash.
  #
  # @param value [Hash, AnnotationsAccessor]
  def annotations=(value)
    self[:annotations] = value.to_h
  end
end
