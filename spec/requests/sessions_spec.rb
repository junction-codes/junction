# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/sessions", type: :request do
  describe "GET /new" do
    it "renders a successful response" do
      get new_session_path
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    let!(:user) { create(:user) }

    context "with valid credentials" do
      it "redirects to the after authentication path" do
        post session_url, params: { email_address: user.email_address, password: user.password }
        expect(response).to redirect_to(root_url)
      end
    end

    context "with invalid credentials" do
      it "redirects to the new session path" do
        post session_url, params: { email_address: user.email_address, password: "wrong_password" }
        expect(response.location).to eq(new_session_url)
      end

      it "sets the forbidden status code" do
        post session_url, params: { email_address: user.email_address, password: "wrong_password" }
        expect(response.status).to eq(403)
      end

      it "sets an alert message" do
        post session_url, params: { email_address: user.email_address, password: "wrong_password" }
        expect(flash[:alert]).to eq("Try another email address or password.")
      end
    end

  #   context "when the rate limit is exceeded" do
  #     it "redirects to the new session path with an alert" do
  #       11.times do
  #         post session_url, params: { email_address: "another@example.com", password: "password" }
  #       end
  #       expect(response.location).to eq(new_session_url)
  #       expect(flash[:alert]).to eq("Try again later.")
  #     end
  #   end
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
