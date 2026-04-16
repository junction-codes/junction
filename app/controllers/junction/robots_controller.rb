# frozen_string_literal: true

module Junction
  # Serves +/robots.txt+ from +public/robots.txt+.
  #
  # To update the actual content, edit +public/robots.txt+.
  class RobotsController < ActionController::Base
    layout false

    protect_from_forgery with: :exception

    CONTENT = Junction::Engine.root.join("public", "robots.txt").read.freeze

    # GET /robots.txt
    def show
      render plain: CONTENT, content_type: "text/plain; charset=utf-8"
    end
  end
end
