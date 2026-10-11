# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::RolesController", type: :request do
  subject!(:role) { create(:role, system_role:) }

  let(:system_role) { false }
  let(:valid_attributes) do
    {
      name: "test-role",
      title: "Test Role",
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
      it_behaves_like "an action that requires permission",
        :get, -> { roles_path }, %w[junction.codes/roles.all.read]

      it "renders a successful response" do
        get roles_url

        expect(response).to be_successful
      end

      it "groups the roles the engine ships separately from our own" do
        get roles_url

        expect(response.body).to include("System roles").and include("Custom roles")
      end

      it "says what each role reaches" do
        get roles_url

        expect(response.body).to match(/\d+ permissions\s+·\s+\d+ groups?/)
      end

      it "says where the permissions themselves come from" do
        get roles_url

        expect(response.body).to include('permissions registered by the engine')
      end

      it "sends the detail pane's links out of the frame" do
        get roles_url

        frame = response.parsed_body.at_css("turbo-frame[id^='role_']")

        expect(frame["target"]).to eq("_top")
      end
    end

    describe "GET /roles/:id" do
      it_behaves_like "an action that requires permission",
        :get, -> { role_path(role) }, %w[junction.codes/roles.all.read]

      it "renders a successful response" do
        get role_url(role)

        expect(response).to be_successful
      end

      it "renders the whole page" do
        get role_url(role)

        expect(response.body).to include("<html")
      end

      it "opens the role that was asked for" do
        get role_url(role)

        tabs = response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")

        expect(tabs["data-ruby-ui--tabs-active-value"])
          .to eq(Junction::Roles::Overview.pane_id(role))
      end

      context "when Turbo asks for the pane" do
        before do
          role.role_permissions.create!(permission: "junction.codes/annotations.all.read")

          get role_url(role),
              headers: { "Turbo-Frame" => "role_#{Junction::Roles::Overview.pane_id(role)}" }
        end

        it "renders the pane alone" do
          expect(response.body).to start_with("<turbo-frame")
        end

        it "marks a permission nothing registers in the table itself" do
          marks = response.parsed_body.css("tbody .sr-only").map(&:text)

          expect(marks).to include("Permission not registered")
        end
      end
    end

    describe "GET /roles/new" do
      it_behaves_like "an action that requires permission",
        :get, -> { new_role_path }, %w[junction.codes/roles.all.write]

      it "renders a successful response" do
        get new_role_url

        expect(response).to be_successful
      end
    end

    describe "GET /roles/:id/edit" do
      it_behaves_like "an action that requires permission",
        :get, -> { edit_role_path(role) }, %w[junction.codes/roles.all.write]

      it "renders a successful response" do
        get edit_role_url(role)

        expect(response).to be_successful
      end
    end

    describe "POST /roles" do
      it_behaves_like "an action that requires permission",
        :post, -> { roles_path },
        %w[junction.codes/roles.all.write junction.codes/roles.owned.write],
        -> { { role: valid_attributes } }

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
      it_behaves_like "an action that requires permission",
        :patch, -> { role_path(role) },
        %w[junction.codes/roles.all.write junction.codes/roles.owned.write],
        { role: { description: "Updated description", permission_ids: [] } }

      context "with valid parameters" do
        let(:new_attributes) do
          { description: "Updated description", permission_ids: [] }
        end

        it "updates the requested role" do
          patch role_url(role), params: { role: new_attributes }
          role.reload

          expect(role.description).to eq("Updated description")
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
      it_behaves_like "an action that requires permission",
        :delete, -> { role_path(role) },
        %w[junction.codes/roles.all.destroy junction.codes/roles.owned.destroy]

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
        let(:system_role) { true }

        it "does not destroy the role" do
          expect {
            delete role_url(role)
          }.not_to change(Junction::Role, :count)
        end

        it "returns a 422 status" do
          delete role_url(role)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end
end
