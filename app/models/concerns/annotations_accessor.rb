# frozen_string_literal: true

# Wraps the `annotations` JSONB hash to allow annotations to be treated like a
# typical Rails model.
class AnnotationsAccessor
  include ActiveModel::Model

  def initialize(object, data)
    @object = object
    @data = (data || {}).with_indifferent_access
  end

  def [](key)
    @data[key]
  end

  # Retrieves the value for a key, with a default if the key is not present.
  #
  # @param key [String, Symbol] The key to look up.
  # @param default [Object] The default value to return if the key is not found.
  # @return [Object] The value associated with the key, or the default.
  def fetch(key, default = nil)
    @data.fetch(key, default)
  end

  def to_h
    @data
  end

  def key?(key)
    @data.key?(key)
  end

  def each(&block)
    @data.each(&block)
  end

  # We use method_missing to dynamically create readers for keys in the hash.
  # This allows for code like `component.annotations.my_simple_key`.
  #
  # We do not define `respond_to_missing?` because we want to treat this object
  # more like a hash than a rigid object. The primary access method for complex
  # keys will remain the `[]` method.
  def method_missing(method_name, *arguments, &block)
    key = method_name.to_s
    if @data.key?(key)
      @data[key]
    elsif PluginRegistry.annotations_for(@object.class).keys.include?(key)
      nil
    else
      super
    end
  end
end
