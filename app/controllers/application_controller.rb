class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # We're using Phlex, so we don't need ActionView to render layouts.
  layout false

  add_flash_types :destructive, :success
end
