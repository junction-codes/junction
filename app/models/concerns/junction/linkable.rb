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

    # Links point outside Junction, so they have to carry a scheme. Without
    # one the browser resolves the value relative to the current page and the
    # link silently stays inside the app.
    URL_FORMAT = /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/

    # An icon name is joined into a filesystem path when it is rendered, so it
    # has to be a plain slug with no dots, no separators, nothing that could
    # walk out of the icon directory.
    ICON_FORMAT = /\A[a-z0-9_-]+\z/

    included do
      attribute :links, :jsonb, default: []

      validate :links_have_urls
      validate :link_urls_are_absolute
      validate :link_icons_are_plain_names
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

    # Validates that every icon name is a plain slug.
    def link_icons_are_plain_names
      return if links.blank?

      offending = links.reject do |link|
        link["icon"].blank? || link["icon"].match?(ICON_FORMAT)
      end

      errors.add(:links, :invalid) if offending.any?
    end

    # Validates that every URL is absolute and http(s).
    def link_urls_are_absolute
      return if links.blank?

      offending = links.reject do |link|
        link["url"].blank? || link["url"].match?(URL_FORMAT)
      end

      errors.add(:links, :invalid) if offending.any?
    end
  end
end
