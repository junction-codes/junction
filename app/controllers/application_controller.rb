# frozen_string_literal: true

# Base controller for the application.
class ApplicationController < ActionController::Base
  include Authentication
  include PluginDispatchHelper

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # We're using Phlex, so we don't need ActionView to render layouts.
  layout false

  add_flash_types :success
end
