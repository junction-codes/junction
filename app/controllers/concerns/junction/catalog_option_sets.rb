# frozen_string_literal: true

module Junction
  # Shared helpers for building catalog option sets in controllers.
  module CatalogOptionSets
    private

    # Type vocabulary for the controller's kind, as name/key pairs for filters.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs.
    def available_types
      Junction::CatalogOptions.section(entity_class.catalog_section)
                              .map { |key, opts| [ opts[:name], key ] }
    end

    # Options for the controller's kind's type field.
    #
    # Declared types are merged with observed values from the database.
    #
    # @return [Hash] Hash of options.
    def type_options
      catalog_options_for(
        Junction::CatalogOptions.section(entity_class.catalog_section),
        [ entity_class, :type ]
      )
    end

    # Returns a hash of catalog options for the given known options and sources.
    #
    # @param known_options [Hash] Known options to include in the catalog.
    # @param sources [Array] Array of tuples containing the model and field to
    #   collect observed values from.
    # @return [Hash] Hash of catalog options.
    def catalog_options_for(known_options, *sources)
      merged_catalog_options(
        known_options,
        observed_values_for(*sources)
      )
    end

    # Returns an array of observed values for the given sources.
    #
    # @param sources [Array] Array of tuples containing the model and field to
    #   collect observed values from.
    # @return [Array] Array of observed values.
    def observed_values_for(*sources)
      sources.flat_map do |(model, field)|
        model.distinct.pluck(field)
      end
    end

    # Merges the known and observed catalog options.
    #
    # @param known_options [Hash] Known options to include in the catalog.
    # @param observed_values [Array] Array of observed values.
    # @return [Hash] Hash of merged catalog options.
    def merged_catalog_options(known_options, observed_values)
      known_options.deep_dup.tap do |merged|
        merged.each_value do |option|
          option[:known] = true unless option.key?(:known)
        end

        observed_values.each do |raw_value|
          value = raw_value.to_s.strip
          next if value.blank? || merged.key?(value)

          merged[value] = {
            key: value,
            name: value.humanize,
            icon: nil,
            description: nil,
            known: false
          }.with_indifferent_access
        end
      end
    end
  end
end
