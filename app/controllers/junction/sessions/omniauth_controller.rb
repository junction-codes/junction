# frozen_string_literal: true

module Junction
  class Sessions::OmniauthController < ApplicationController
    allow_unauthenticated_access only: %i[ callback ]

    # GET /auth/:provider/callback
    def callback
      auth = request.env["omniauth.auth"]
      user = User.from_omniauth(auth)

      if user&.persisted?
        start_new_session_for user
        redirect_to root_path, notice: "Successfully signed in with #{auth.provider.humanize}."
      else
        redirect_to new_session_path, alert: "Authentication failed."
      end
    end

    # GET /auth/failure
    def failure
      redirect_to new_session_path, alert: "Authentication failed."
    end
  end
end
