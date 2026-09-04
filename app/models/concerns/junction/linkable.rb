# frozen_string_literal: true

module Junction
  # Provides access to the `links` jsonb field.
  #
  # This field is a list of external references such as dashboards, runbooks,
  # and admin tools. Each link has a `url`, an optional `title`, and an optional
  # `icon`.
  module Linkable
    extend ActiveSupport::Concern

    LINK_KEYS = %w[url title icon].freeze

    included do
      attribute :links, :jsonb, default: []

      validate :links_have_urls
    end

    # Sets the links, discarding blank rows and unknown keys.
    #
    # Form input arrives as a hash of indexed rows rather than an array, so
    # both shapes are accepted.
    #
    # @param value [Array<Hash>, Hash, nil] The links to assign.
    def links=(value)
      super(normalize_links(value))
    end

    private

    # Normalizes assorted input shapes into an array of link hashes.
    #
    # @param value [Array<Hash>, Hash, nil] The raw value.
    # @return [Array<Hash>] The normalized links.
    def normalize_links(value)
      rows = case value
      when nil then []
      when Hash then value.values
      else Array(value)
      end

      rows.filter_map do |row|
        next unless row.respond_to?(:to_h)

        link = row.to_h.with_indifferent_access.slice(*LINK_KEYS)
                  .transform_values { |v| v.to_s.strip }
                  .reject { |_, v| v.blank? }
        link.presence
      end
    end

    # Validates that every link carries a URL.
    def links_have_urls
      return if links.blank?

      errors.add(:links, :blank) if links.any? { |link| link["url"].blank? }
    end
  end
end
