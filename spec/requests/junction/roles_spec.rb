# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::RolesController", type: :request do
  subject!(:role) { create(:role, system:) }

  let(:system) { false }
  let(:valid_attributes) do
    {
      name: "Test Role",
      description: "A role for testing purposes",
      permission_ids: []
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      description: "",
      permission_ids: []
    }
  end

  context "when the user is not authenticated" do
    describe "GET /roles" do
      it_behaves_like "an action that requires authentication", :get, -> { roles_path }
    end

    describe "GET /roles/:id" do
      it_behaves_like "an action that requires authentication", :get, -> { role_path(role) }
    end

    describe "GET /roles/new" do
      it_behaves_like "an action that requires authentication", :get, -> { new_role_path }
    end

    describe "GET /roles/:id/edit" do
      it_behaves_like "an action that requires authentication", :get, -> { edit_role_path(role) }
    end

    describe "POST /roles" do
      it_behaves_like "an action that requires authentication", :post, -> { roles_path }
    end

    describe "PATCH /roles/:id" do
      it_behaves_like "an action that requires authentication", :patch, -> { role_path(role) }
    end

    describe "DELETE /roles/:id" do
      it_behaves_like "an action that requires authentication", :delete, -> { role_path(role) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /roles" do
      it "renders a successful response" do
        get roles_url

        expect(response).to be_successful
      end
    end

    describe "GET /roles/:id" do
      it "renders a successful response" do
        get role_url(role)

        expect(response).to be_successful
      end
    end

    describe "GET /roles/new" do
      it "renders a successful response" do
        get new_role_url

        expect(response).to be_successful
      end
    end

    describe "GET /roles/:id/edit" do
      it "renders a successful response" do
        get edit_role_url(role)

        expect(response).to be_successful
      end
    end

    describe "POST /roles" do
      context "with valid parameters" do
        it "creates a new role" do
          expect {
            post roles_url, params: { role: valid_attributes }
          }.to change(Junction::Role, :count).by(1)
        end

        it "redirects to the created role" do
          post roles_url, params: { role: valid_attributes }

          expect(response).to redirect_to(role_url(Junction::Role.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new role" do
          expect {
            post roles_url, params: { role: invalid_attributes }
          }.not_to change(Junction::Role, :count)
        end

        it "renders a response with 422 status" do
          post roles_url, params: { role: invalid_attributes }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /roles/:id" do
      context "with valid parameters" do
        let(:new_attributes) do
          { name: "Updated Role Name", description: "Updated description", permission_ids: [] }
        end

        it "updates the requested role" do
          patch role_url(role), params: { role: new_attributes }
          role.reload

          expect(role.name).to eq("Updated Role Name")
        end

        it "redirects to the role" do
          patch role_url(role), params: { role: new_attributes }

          expect(response).to redirect_to(role_url(role))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status" do
          patch role_url(role), params: { role: invalid_attributes }

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /roles/:id" do
      context "when the role is not a system role" do
        it "destroys the requested role" do
          expect {
            delete role_url(role)
          }.to change(Junction::Role, :count).by(-1)
        end

        it "redirects to the roles list" do
          delete role_url(role)

          expect(response).to redirect_to(roles_url)
        end

        it "returns 303 See Other" do
          delete role_url(role)

          expect(response).to have_http_status(:see_other)
        end
      end

      context "when the role is a system role" do
        let(:system) { true }

        it "does not destroy the role" do
          expect {
            delete role_url(role)
          }.not_to change(Junction::Role, :count)
        end

        it "returns 422 Unprocessable Entity" do
          delete role_url(role)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
