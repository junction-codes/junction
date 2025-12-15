# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/users", type: :request do
  let!(:user) { create(:user) }

  let(:valid_attributes) do
    password = random_password
    {
      display_name: "New User",
      email_address: "new@example.com",
      email_address_confirmation: "new@example.com",
      password: password,
      password_confirmation: password
    }
  end

  let(:invalid_attributes) do
    {
      display_name: "",
      email_address: "invalid-email",
      password: "short",
      password_confirmation: "does-not-match"
    }
  end

  context "when the user is not authenticated" do
    describe "GET /index" do
      it_behaves_like 'an action that requires authentication', :get, -> { users_path }
    end

    describe "GET /show" do
      it_behaves_like 'an action that requires authentication', :get, -> { user_path(user) }
    end

    describe "GET /new" do
      it_behaves_like 'an action that requires authentication', :get, -> { new_user_path }
    end

    describe "GET /edit" do
      it_behaves_like 'an action that requires authentication', :get, -> { edit_user_path(user) }
    end

    describe "POST /create" do
      it_behaves_like 'an action that requires authentication', :post, -> { users_path }
    end

    describe "PATCH /update" do
      it_behaves_like 'an action that requires authentication', :patch, -> { user_path(user) }
    end

    describe "DELETE /destroy" do
      it_behaves_like 'an action that requires authentication', :delete, -> { user_path(user) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /index" do
      it "renders a successful response" do
        get users_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        get user_url(user)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_user_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "renders a successful response" do
        get edit_user_url(user)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new User" do
          expect {
            post users_url, params: { user: valid_attributes }
          }.to change(User, :count).by(1)
        end

        it "redirects to the created user" do
          post users_url, params: { user: valid_attributes }
          expect(response).to redirect_to(user_url(User.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new User" do
          expect {
            post users_url, params: { user: invalid_attributes }
          }.not_to change(User, :count)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post users_url, params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) { { display_name: "Updated Name" } }

        it "updates the requested user" do
          patch user_url(user), params: { user: new_attributes }
          user.reload
          expect(user.display_name).to eq("Updated Name")
        end

        it "redirects to the user" do
          patch user_url(user), params: { user: new_attributes }
          user.reload
          expect(response).to redirect_to(user_url(user))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          patch user_url(user), params: { user: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested user" do
        user_to_delete = create(:user)
        expect {
          delete user_url(user_to_delete)
        }.to change(User, :count).by(-1)
      end

      it "redirects to the users list" do
        delete user_url(user)
        expect(response).to redirect_to(users_url)
      end
    end
  end
end
