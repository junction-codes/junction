# frozen_string_literal: true

require "junction/engine"
require "junction/version"
require "junction/catalog_options"
require "junction/instrumentation"

require_relative "../app/values/junction/permission"
require_relative "../app/services/junction/application_plugin"

module Junction
  mattr_accessor :config
  self.config = ActiveSupport::OrderedOptions.new
end
