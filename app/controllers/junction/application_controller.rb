# frozen_string_literal: true

module Junction
  # Base controller for the Junction engine.
  class ApplicationController < ActionController::Base
    include Junction::Authentication
    include PluginDispatchHelper
    include Engine.routes.url_helpers

    allow_browser versions: :modern

    # We're using Phlex, so we don't need ActionView to render layouts.
    layout false

    add_flash_types :success
  end
end
