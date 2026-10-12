# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/passwords", type: :request do
  let(:user) { create(:user) }

  describe "GET /new" do
    it "renders a successful response" do
      get new_password_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with an existing user's email" do
      it "sends a password reset email" do
        expect {
          post passwords_url, params: { email: user.email }
        }.to have_enqueued_mail(Junction::PasswordsMailer, :reset).with(user)
      end

      it "returns to the reset page" do
        post passwords_url, params: { email: user.email }
        expect(response).to redirect_to(new_password_url)
      end

      it "confirms a link is on its way" do
        post passwords_url, params: { email: user.email }
        follow_redirect!

        expect(response.body).to include("Check your email")
      end
    end

    context "with a non-existent user's email" do
      it "does not send a password reset email" do
        expect {
          post passwords_url, params: { email: "nonexistent@example.com" }
        }.not_to have_enqueued_mail(Junction::PasswordsMailer, :reset)
      end

      it "returns to the reset page" do
        post passwords_url, params: { email: "nonexistent@example.com" }
        expect(response).to redirect_to(new_password_url)
      end

      it "gives the same confirmation, to prevent email enumeration" do
        post passwords_url, params: { email: "nonexistent@example.com" }
        follow_redirect!

        expect(response.body).to include("Check your email")
      end

      it "names the address back without claiming it exists" do
        post passwords_url, params: { email: "nonexistent@example.com" }
        follow_redirect!

        expect(response.body).to include("If nonexistent@example.com has an account")
      end
    end

    context "with a value no address could be" do
      it "survives one longer than the cookie would hold" do
        post passwords_url, params: { email: "a" * 8_000 }

        expect(response).to redirect_to(new_password_url)
      end

      it "keeps only an address's worth of it" do
        post passwords_url, params: { email: "a" * 8_000 }
        follow_redirect!

        expect(response.body).to include("If #{'a' * 254} has an account")
      end

      it "does not widen the lookup to several addresses" do
        expect {
          post passwords_url, params: { email: [ user.email, "other@example.com" ] }
        }.not_to have_enqueued_mail(Junction::PasswordsMailer, :reset)
      end
    end
  end

  describe "GET /edit" do
    let(:token) { user.password_reset_token }

    context "with a valid token" do
      it "renders a successful response" do
        get edit_password_url(token)
        expect(response).to be_successful
      end
    end

    context "with an invalid token" do
      it "redirects to the new password path" do
        get edit_password_url("invalid_token")
        expect(response).to redirect_to(new_password_url)
      end

      it "sets an alert message" do
        get edit_password_url("invalid_token")
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end
    end
  end

  describe "PATCH /update" do
    let(:token) { user.password_reset_token }

    context "with a valid token and matching passwords" do
      let(:valid_attributes) do
        password = random_password
        { password:, password_confirmation: password }
      end

      it "updates the user's password" do
        patch password_url(token), params: valid_attributes
        expect(user.reload.authenticate(valid_attributes[:password])).to be_truthy
      end

      it "redirects to the new session path" do
        patch password_url(token), params: valid_attributes
        expect(response).to redirect_to(new_session_url)
      end

      it "sets a success notice" do
        patch password_url(token), params: valid_attributes
        expect(flash[:success]).to eq("Password has been reset.")
      end
    end

    context "with a valid token but non-matching passwords" do
      let(:invalid_attributes) { { password: "new_password", password_confirmation: "wrong_confirmation" } }

      it "does not update the user's password" do
        expect {
          patch password_url(token), params: invalid_attributes
        }.not_to change { user.credential.reload.password_digest }
      end

      it "redirects to the edit password path" do
        patch password_url(token), params: invalid_attributes
        expect(response).to redirect_to(edit_password_url(token))
      end

      it "sets an alert message" do
        patch password_url(token), params: invalid_attributes
        expect(flash[:alert]).to eq("Passwords did not match.")
      end
    end

    context "with a valid token but invalid passwords" do
      let(:invalid_attributes) { { password: "password", password_confirmation: "password" } }

      it "does not update the user's password" do
        expect {
          patch password_url(token), params: invalid_attributes
        }.not_to change { user.credential.reload.password_digest }
      end

      it "redirects to the edit password path" do
        patch password_url(token), params: invalid_attributes
        expect(response).to redirect_to(edit_password_url(token))
      end

      it "sets an alert message" do
        patch password_url(token), params: invalid_attributes
        expect(flash[:alert]).to eq("Passwords did not match.")
      end
    end

    context "with an invalid token" do
      let(:valid_attributes) { { password: "new_password", password_confirmation: "new_password" } }

      it "redirects to the new password path" do
        patch password_url("invalid_token"), params: valid_attributes
        expect(response).to redirect_to(new_password_url)
      end

      it "sets an alert message" do
        patch password_url("invalid_token"), params: valid_attributes
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end
    end
  end
end
