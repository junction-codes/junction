# frozen_string_literal: true

module Junction
  # Provides specialized access to the 'annotations' jsonb field.
  #
  # @todo Support validation of annotations.
  module Annotated
    extend ActiveSupport::Concern

    included do
      attribute :annotations, :jsonb, default: {}

      before_validation :merge_other_annotations
    end

    class_methods do
      # Plugin-registered annotation keys for this model.
      #
      # @return [Array<String>]
      def known_annotation_keys
        PluginRegistry.annotations_for(self).keys
      end
    end

    # Rows for the other-annotations form section.
    #
    # @return [Array<Hash>] Each hash has +:key+ and +:value+.
    def other_annotation_rows
      known_keys = self.class.known_annotation_keys
      raw = (self[:annotations] || {}).stringify_keys
      rows = raw.except(*known_keys).map do |key, value|
        { key:, value: value.to_s }
      end

      rows << { key: "", value: "" } unless rows.any? { |row| row[:key].blank? }
      rows
    end

    # Virtual attribute for other-annotation form rows.
    #
    # @param value [Array<Hash>]
    def other_annotations=(value)
      @other_annotations = normalize_other_annotation_rows(value)
      @other_annotations_assigned = true
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
    # The value may be our custom accessor class, but the database expects a
    # hash.
    #
    # @param value [Hash, AnnotationsAccessor]
    def annotations=(value)
      self[:annotations] = value.to_h
    end

    # Determines whether a specific annotation has been changed.
    #
    # @param annotation [String] The annotation to check.
    # @return [Boolean] Whether or not the annotation's value has changed.
    def annotation_changed?(annotation)
      return false unless annotations_changed?

      old_values, new_values = annotations_change
      old_values&.fetch(annotation, nil) != new_values&.fetch(annotation, nil)
    end

    private

    # Merges known and other annotations into the annotations attribute.
    #
    # Only performs the merge if @other_annotations_assigned is true.
    def merge_other_annotations
      return unless @other_annotations_assigned

      known_keys = self.class.known_annotation_keys
      known = (self[:annotations] || {}).stringify_keys.slice(*known_keys)
      other = build_other_annotations_hash(known_keys)
      self[:annotations] = known.merge(other)
    end

    # Builds a hash of other annotations, excluding known annotation keys.
    #
    # @param known_keys [Array<String>] The list of known annotation keys to0
    #   exclude.
    # @return [Hash<String, String>] A hash of user-supplied (other) annotation
    #   keys and values.
    def build_other_annotations_hash(known_keys)
      normalize_other_annotation_rows(@other_annotations).each_with_object({}) do |row, hash|
        key = row[:key].to_s.strip
        next if key.blank?
        next if known_keys.include?(key)

        hash[key] = row[:value].to_s
      end
    end

    # Normalizes a value into an array of annotation row hashes with string keys
    # and values.
    #
    # @param value [Array, Hash, nil] The raw value, potentially from the form
    #   or the database.
    # @return [Array<Hash<String, String>>] The normalized array of annotation
    #   rows.
    def normalize_other_annotation_rows(value)
      rows = case value
      when nil then []
      when Array then value
      when Hash then value.values
      else Array(value)
      end

      rows.filter_map do |row|
        next unless row.respond_to?(:to_h)

        data = row.to_h.with_indifferent_access
        { key: data[:key].to_s, value: data[:value].to_s }
      end
    end
  end
end
