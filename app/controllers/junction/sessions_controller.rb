# frozen_string_literal: true

module Junction
  # Controller for managing user sessions.
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: %i[ new create ]
    skip_verify_authorized if respond_to?(:skip_verify_authorized, true)
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { too_many_attempts }

    # GET /sessions/new
    def new
      render Views::Sessions::New
    end

    # POST /sessions
    def create
      user = User.authenticate_by(params.permit(:email, :password))
      if user
        start_new_session_for user
        redirect_to after_authentication_url
      else
        flash.now[:alert] = "Try another email address or password."
        render Views::Sessions::New, status: :unprocessable_content
      end
    end

    # DELETE /sessions
    def destroy
      terminate_session
      redirect_to new_session_path
    end

    private

    # Answers an rate limited request.
    def too_many_attempts
      flash.now[:alert] = "Too many attempts. Try again in a few minutes."
      render Views::Sessions::New, status: :too_many_requests
    end
  end
end
