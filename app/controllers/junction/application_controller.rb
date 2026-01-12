# frozen_string_literal: true

module Junction
  # Base controller for the Junction engine.
  # Host applications can include concerns or override behavior as needed.
  class ApplicationController < ActionController::Base
    include Authentication
    include PluginDispatchHelper
    include Engine.routes.url_helpers

    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern

    # We're using Phlex, so we don't need ActionView to render layouts.
    layout false

    add_flash_types :success
  end
end
