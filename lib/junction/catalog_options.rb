# frozen_string_literal: true

module Junction
  # A simple singleton module to load and provide access to catalog options.
  #
  # Options are loaded from `config/catalog_options.yaml` within this engine by
  # default, but can be overridden by placing a file of the same name in the
  # host application's `config` directory.
  #
  # @todo Revisit this implementation to use Rails configuration or another
  #   approach that better fits with Rails conventions.
  module CatalogOptions
    DEFAULT_PATH = File.join(__dir__, "..", "..", "config", "catalog_options.yaml").freeze
    SECTION_BY_FIELD = {
      api_type: :apis,
      component_type: :kinds,
      domain_type: :domains,
      group_type: :group_types,
      lifecycle: :lifecycles,
      resource_type: :resources
    }.freeze

    # Returns the cached, normalized catalog options.
    #
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def self.options
      @options ||= load_options
    end

    # Reloads options from disk and refreshes the in-memory cache.
    #
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def self.reload!
      @options = load_options
    end

    # Clears the cached options so the next call to {options} reloads them.
    #
    # @return [nil]
    def self.reset!
      @options = nil
    end

    def self.apis
      options.fetch(:apis, {}.with_indifferent_access)
    end

    def self.domains
      options.fetch(:domains, {}.with_indifferent_access)
    end

    def self.group_types
      options.fetch(:group_types, {}.with_indifferent_access)
    end

    def self.kinds
      options.fetch(:kinds, {}.with_indifferent_access)
    end

    def self.lifecycles
      options.fetch(:lifecycles, {}.with_indifferent_access)
    end

    def self.resources
      options.fetch(:resources, {}.with_indifferent_access)
    end

    # Returns the section map used by field-based lookup helpers.
    #
    # @return [Hash<Symbol, Symbol>]
    def self.section_by_field
      SECTION_BY_FIELD
    end

    # Resolves a field name to a catalog section key.
    #
    # @param field [String, Symbol] Field identifier (for example, :api_type).
    # @return [Symbol] Catalog section key.
    def self.section_for(field)
      SECTION_BY_FIELD.fetch(field.to_sym)
    end

    # Returns known options for the given field.
    #
    # @param field [String, Symbol]
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def self.known_for(field)
      options.fetch(section_for(field), {}.with_indifferent_access)
    end

    # Returns known option keys for the given field.
    #
    # @param field [String, Symbol]
    # @return [Array<String>]
    def self.known_values_for(field)
      known_for(field).keys
    end

    # Checks whether a value is a known option for a field.
    #
    # @param field [String, Symbol]
    # @param value [String]
    # @return [Boolean]
    def self.known_option?(field, value)
      known_for(field).key?(value.to_s)
    end

    # Validates that configured sections do not contain blank option keys.
    #
    # @return [Boolean] True when validation succeeds.
    #
    # @raise [ArgumentError] If a section contains a blank key.
    def self.validate!
      SECTION_BY_FIELD.values.uniq.each do |section|
        values = options.fetch(section, {})
        next unless values.respond_to?(:keys)

        values.keys.each do |key|
          raise ArgumentError, "Catalog options contain a blank key in #{section}" if key.blank?
        end
      end

      true
    end

    # Loads and normalizes options from the override file or default path.
    #
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def self.load_options
      override_path = Rails.root.join("config", "catalog_options.yaml")
      path = override_path.exist? ? override_path : DEFAULT_PATH
      normalize_options(YAML.load_file(path).with_indifferent_access)
    end

    # Normalizes all option sections to a consistent structure.
    #
    # @param raw_options [Hash]
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def self.normalize_options(raw_options)
      raw_options.each_with_object({}.with_indifferent_access) do |(section, section_options), out|
        out[section] = normalize_section(section_options)
      end
    end

    # Normalizes a single section of key/value option entries.
    #
    # @param section_options [Hash]
    # @return [ActiveSupport::HashWithIndifferentAccess]
    def self.normalize_section(section_options)
      return {}.with_indifferent_access unless section_options.respond_to?(:each_pair)

      section_options.each_with_object({}.with_indifferent_access) do |(key, attrs), out|
        option_key = key.to_s
        option_attrs = attrs.is_a?(Hash) ? attrs.with_indifferent_access : {}.with_indifferent_access
        normalized = option_attrs.except(:id)
        normalized[:key] = option_key
        normalized[:name] = option_attrs[:name].presence || option_key.humanize
        normalized[:icon] = option_attrs[:icon]
        normalized[:description] = option_attrs[:description]
        out[option_key] = normalized
      end
    end
  end
end
