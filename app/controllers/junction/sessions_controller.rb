# frozen_string_literal: true

# Controller for managing user sessions.
module Junction
  class SessionsController < Junction::ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later.", status: :too_many_requests }

  # GET /sessions/new
  def new
    render Views::Sessions::New
  end

  # POST /sessions
  def create
    user = User.authenticate_by(params.permit(:email_address, :password))
    if user
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password.", status: :forbidden
    end
  end

  # DELETE /sessions
  def destroy
    terminate_session
    redirect_to new_session_path
  end
  end
end
