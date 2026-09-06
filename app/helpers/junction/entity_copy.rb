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

      {
        kind: name.human,
        kind_lower: lowercase_kind(name.human),
        kinds: name.human(count: 2),
        kinds_lower: lowercase_kind(name.human(count: 2))
      }
    end

    # Lowercases a kind name unless it is an acronym.
    #
    # "Component" reads as "component" mid-sentence, but "API" has to stay
    # "API".
    #
    # @param name [String] The kind's name.
    # @return [String] The name as it reads mid-sentence.
    def lowercase_kind(name)
      name == name.upcase ? name : name.downcase
    end
  end
end
