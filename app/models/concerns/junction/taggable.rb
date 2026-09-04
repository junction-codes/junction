# frozen_string_literal: true

module Junction
  # Provides access to the `tags` and `labels` fields.
  #
  # These are Backstage's `metadata.tags` (a bare string list) and
  # `metadata.labels` (its key/value counterpart). Tags are a Postgres array
  # rather than jsonb so they can be matched with the array overlap operator
  # and counted with `unnest`.
  module Taggable
    extend ActiveSupport::Concern

    TAG_FORMAT = /\A[a-z0-9][a-z0-9+#\-.]*\z/

    included do
      attribute :labels, :jsonb, default: {}

      validate :tags_are_well_formed

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
    # @param value [Hash, nil] The labels to assign.
    def labels=(value)
      super((value || {}).to_h.transform_keys { |k| k.to_s.strip }
                              .transform_values(&:to_s)
                              .reject { |key, _| key.blank? })
    end

    private

    # Normalizes assorted input shapes into a list of unique tags.
    #
    # @param value [Array<String>, String, nil] The raw value.
    # @return [Array<String>] The normalized tags.
    def normalize_tags(value)
      list = value.is_a?(String) ? value.split(",") : Array(value)
      list.map { |tag| tag.to_s.strip.downcase }.reject(&:blank?).uniq
    end

    # Validates that every tag matches the expected tag format.
    def tags_are_well_formed
      return if tags.blank?

      return if tags.all? { |tag| tag.match?(TAG_FORMAT) && tag.length <= 63 }

      errors.add(:tags, :invalid)
    end
  end
end
