# frozen_string_literal: true

module Junction
  # Provides access to the `tags` and `labels` fields.
  #
  # Tags are a Postgres array rather than jsonb so they can be matched with the
  # array overlap operator and counted with `unnest`.
  module Taggable
    extend ActiveSupport::Concern

    TAG_FORMAT = /\A[a-z0-9][a-z0-9+#\-.]*\z/

    included do
      attribute :labels, :jsonb, default: {}

      validate :tags_are_well_formed
      before_validation :merge_label_rows

      # Entities carrying every one of the given tags.
      scope :tagged_with, lambda { |*tags|
        where("tags @> ARRAY[?]::varchar[]", tags.flatten.map(&:to_s))
      }

      # Entities carrying any of the given tags.
      scope :tagged_with_any, lambda { |*tags|
        where("tags && ARRAY[?]::varchar[]", tags.flatten.map(&:to_s))
      }
    end

    # Sets the tags, accepting either a list or a comma-separated string.
    #
    # @param value [Array<String>, String, nil] The tags to assign.
    def tags=(value)
      super(normalize_tags(value))
    end

    # Sets the labels, discarding rows with a blank key.
    #
    # Takes the labels themselves. A form editing them submits {#label_rows=}
    # instead, because a key/value editor has to let the key be edited too,
    # which it cannot do while the key is the parameter name.
    #
    # @param value [Hash, nil] The labels to assign.
    def labels=(value)
      super((value || {}).to_h.transform_keys { |k| k.to_s.strip }
                              .transform_values(&:to_s)
                              .reject { |key, _| key.blank? })
    end

    # Rows for the labels form section.
    #
    # Always ends with a blank row, so the form has somewhere to type the next
    # pair without pressing "add" first.
    #
    # @return [Array<Hash>] Each hash has +:key+ and +:value+.
    def label_rows
      rows = labels.map { |key, value| { key: key.to_s, value: value.to_s } }
      rows << { key: "", value: "" } unless rows.any? { |row| row[:key].blank? }
      rows
    end

    # Virtual attribute for the labels form section.
    #
    # Held until validation rather than assigned straight through, so that a
    # form which submits no rows at all leaves the labels alone while one that
    # submits an empty set clears them.
    #
    # @param value [Array<Hash>, Hash, nil] The rows to assign.
    def label_rows=(value)
      @label_rows = normalize_label_rows(value)
      @label_rows_assigned = true
    end

    private

    # Replaces the labels with whatever the form submitted.
    #
    # The rows are consumed rather than kept, so a later write to `labels` on
    # the same object is not silently overwritten by a stale submission the
    # next time validation runs.
    def merge_label_rows
      return unless @label_rows_assigned

      rows = @label_rows
      @label_rows = nil
      @label_rows_assigned = false

      self.labels = rows.each_with_object({}) do |row, hash|
        key = row[:key].to_s.strip
        next if key.blank?

        hash[key] = row[:value].to_s
      end
    end

    # Normalizes assorted input shapes into a list of label rows.
    #
    # Form input arrives as a hash of indexed rows rather than an array, so
    # both shapes are accepted.
    #
    # @param value [Array<Hash>, Hash, nil] The raw value.
    # @return [Array<Hash>] The normalized rows.
    def normalize_label_rows(value)
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

    # Normalizes assorted input shapes into a list of unique tags.
    #
    # Each entry is split on commas, not just a bare string. A chip editor
    # submits a list, and one of its entries can still hold a list that wasn't
    # split client side.
    #
    # @param value [Array<String>, String, nil] The raw value.
    # @return [Array<String>] The normalized tags.
    def normalize_tags(value)
      Array(value).flat_map { |tag| tag.to_s.split(",") }
                  .map { |tag| tag.strip.downcase }
                  .reject(&:blank?)
                  .uniq
    end

    # Validates that every tag matches the expected tag format.
    def tags_are_well_formed
      return if tags.blank?

      return if tags.all? { |tag| tag.match?(TAG_FORMAT) && tag.length <= 63 }

      errors.add(:tags, :invalid)
    end
  end
end
