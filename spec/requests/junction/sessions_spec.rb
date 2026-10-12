# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/sessions", type: :request do
  describe "GET /new" do
    it "renders a successful response" do
      get new_session_path
      expect(response).to be_successful
    end

    it "says where accounts come from" do
      get new_session_path

      expect(response.body).to include("Accounts are created by an admin")
    end

    it "offers the way out of a forgotten password" do
      get new_session_path

      expect(response.body).to include(new_password_path)
    end

    it "shows the Junction mark" do
      get new_session_path

      expect(response.body).to include("M6.7 19.5h10.6")
    end

    context "when the installation configured an icon of its own" do
      before { allow(Junction.config).to receive(:icon).and_return("train-track") }

      it "shows that icon in place of the mark" do
        get new_session_path

        expect(response.body).not_to include("M6.7 19.5h10.6")
      end
    end

    context "when demo mode is configured" do
      before { allow(Junction.config).to receive(:allow_demo_mode).and_return(true) }

      it "says the catalog can be read without an account" do
        get new_session_path

        expect(response.body).to include("Demo mode is on")
      end
    end

    context "without demo mode" do
      it "says nothing about it" do
        get new_session_path

        expect(response.body).not_to include("Demo mode is on")
      end
    end

    context "when a password was just reset" do
      let(:user) { create(:user) }

      it "carries the confirmation onto the page" do
        password = random_password
        patch password_url(user.password_reset_token),
              params: { password:, password_confirmation: password }
        get new_session_path

        expect(response.body).to include("Password has been reset.")
      end
    end
  end

  describe "POST /create" do
    let!(:user) { create(:user) }

    context "with valid credentials" do
      it "redirects to the after authentication path" do
        post session_url, params: { email: user.email, password: user.password }
        expect(response).to redirect_to(root_url)
      end
    end

    context "with invalid credentials" do
      before do
        post session_url, params: { email: user.email, password: "wrong_password" }
      end

      it "renders the sign-in page again" do
        expect(response.body).to include("Sign in")
      end

      it "sets the unprocessable status code" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "shows the alert without naming which half failed" do
        expect(response.body).to include("Try another email address or password.")
      end
    end
  end

  describe "DELETE /destroy" do
    context "when authenticated" do
      let(:user) { create(:user) }

      before do
        sign_in user:, password: user.password
      end

      it "redirects to the new session path" do
        delete session_url(user)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when not authenticated" do
      it_behaves_like 'an action that requires authentication', :delete, -> { session_path }
    end
  end
end
