# frozen_string_literal: true

require "junction/engine"
require "junction/version"
require "junction/catalog_options"
require_relative "../app/services/junction/plugin"

module Junction
  mattr_accessor :config
  self.config = ActiveSupport::OrderedOptions.new
end
