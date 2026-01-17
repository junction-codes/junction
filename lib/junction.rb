# frozen_string_literal: true

require "junction/engine"
require "junction/version"
require "junction/catalog_options"

module Junction
  mattr_accessor :config
  self.config = ActiveSupport::OrderedOptions.new
end
