# frozen_string_literal: true

module Junction
  # Supplies the kind's name to copy shared across every entity kind.
  #
  # One set of strings serves all of them by naming the kind through
  # interpolation, so "Delete Component" and "Delete API" are the same entry.
  # Including this adds three interpolations to every relative lookup:
  #
  # - `%{kind}` - the kind's name, e.g. "Component", "API".
  # - `%{kind_lower}` - the same, lowercased unless it is an acronym, for use
  #   mid-sentence: "your new component", "your new API".
  # - `%{kinds}` - the plural, e.g. "Components", "APIs".
  #
  # Including classes name the kind by defining {#copy_model}.
  module EntityCopy
    # Translates a key, naming the kind for relative lookups.
    #
    # @param key [String] The translation key.
    # @param options [Hash] Interpolations and options for I18n.
    # @return [String] The translation.
    def translate(key, **options)
      return super unless key.to_s.start_with?(".")

      super(key, **kind_interpolations, **options)
    end
    alias_method :t, :translate

    private

    # The kind whose name the shared copy interpolates.
    #
    # @return [Class] The entity class.
    #
    # @raise [NotImplementedError] If not overridden.
    def copy_model
      raise NotImplementedError, "#{self.class} must define #copy_model"
    end

    # Names for the kind, in the forms the shared copy needs.
    #
    # @return [Hash] The interpolations.
    def kind_interpolations
      name = copy_model.model_name
      singular = name.human
      plural = name.human(count: 2)

      {
        kind: singular,
        kind_lower: acronym?(singular) ? singular : singular.downcase,
        kinds: plural,
        kinds_lower: acronym?(singular) ? plural : plural.downcase
      }
    end

    # Whether a kind's name is an acronym and should retain its case.
    #
    # @param singular [String] The kind's name.
    # @return [Boolean] Whether it is an acronym.
    def acronym?(singular)
      singular == singular.upcase
    end
  end
end
