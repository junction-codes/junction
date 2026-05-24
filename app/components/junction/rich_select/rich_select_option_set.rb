# frozen_string_literal: true

module Junction
  module Components
    module RichSelect
      # Encapsulates option lookup/partition behavior for RichSelect.
      class RichSelectOptionSet
        # Initializes a new option set.
        #
        # @param options [Hash] Options for the set.
        # @param default_icon [String] Default icon for options in the set.
        def initialize(options, default_icon:)
          @options = options
          @default_icon = default_icon
        end

        # Returns the IDs of known options in the set.
        #
        # @return [Array<String>] The IDs of known options.
        def known_ids
          @options.each_with_object([]) do |(id, option), ids|
            ids << id if known?(option)
          end
        end

        # Returns the IDs of other options in the set.
        #
        # @return [Array<String>] The IDs of "other" options.
        def other_ids
          @options.each_with_object([]) do |(id, option), ids|
            ids << id unless known?(option)
          end
        end

        # Returns the option data for a given ID.
        #
        # @param id [String] ID of the option to fetch.
        # @return [Hash] The option data.
        def fetch(id)
          @options.fetch(id, { name: id.humanize, description: nil, icon: @default_icon })
        end

        # Returns the text used for search matching against an option.
        #
        # @param id [String] ID of the option to fetch.
        # @return [String] The text used for search matching.
        def search_text(id)
          option = fetch(id)
          [ id, option[:name], option[:description] ].compact.join(" ").downcase
        end

        private

        # Checks if an option is known.
        #
        # @param option [Hash] The option to check.
        # @return [Boolean] Whether the option is known or not.
        def known?(option)
          return true unless option.is_a?(Hash)

          known_value = option[:known]
          return true if known_value.nil?

          known_value
        end
      end
    end
  end
end
