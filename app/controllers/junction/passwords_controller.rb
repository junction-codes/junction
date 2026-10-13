# frozen_string_literal: true

module Junction
  # Controller for managing user password resets.
  class PasswordsController < ApplicationController
    # The longest an email address can be. RFC 5321 caps a path at 256 octets
    # including the angle brackets around it.
    MAX_EMAIL_LENGTH = 254

    allow_unauthenticated_access
    skip_verify_authorized

    before_action :set_user_by_token, only: %i[ edit update ]

    # GET /passwords/new
    def new
      render Views::Passwords::New.new(sent_to: flash[:sent_to])
    end

    # POST /passwords
    #
    # We always report success, even if no user was found. Revealing the
    # presence or absence of an email address would provide sensitive
    # information to a potential attacker.
    def create
      user = User.find_by(email: submitted_email) if submitted_email.present?
      PasswordsMailer.reset(user).deliver_later if user

      redirect_to new_password_path, flash: { sent_to: submitted_email }
    end

    # GET /passwords/:token/edit
    def edit
      render Views::Passwords::Edit.new(token: params[:token])
    end

    # PATCH/PUT /passwords/:token
    def update
      if @user.update(params.permit(:password, :password_confirmation))
        redirect_to new_session_path, success: "Password has been reset."
      else
        redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
      end
    end

    private

    # Returns the address a reset was asked for.
    #
    # The email address is accepted only as a string of at most
    # {MAX_EMAIL_LENGTH} characters. Anything else is dropped.
    #
    # @return [String] The address, or an empty string.
    def submitted_email
      @submitted_email ||= begin
        email = params[:email]

        email.is_a?(String) && email.length <= MAX_EMAIL_LENGTH ? email : ""
      end
    end

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
  end
end
