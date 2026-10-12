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

  describe "the permission editor" do
    let(:role) { create(:role) }

    before do
      sign_in_user_with_permissions(%w[
        junction.codes/roles.all.read junction.codes/roles.all.write
      ])

      role.role_permissions.create!(permission: "junction.codes/components.all.read")

      get edit_role_path(namespace: role.namespace, name: role.name)
    end

    it "offers a checkbox for every registered permission" do
      boxes = response.parsed_body.css("input[type='checkbox'][name*='permission_ids']")

      expect(boxes.size).to eq(Junction::PluginRegistry.permissions.size)
    end

    it "records what each permission loaded as" do
      box = response.parsed_body
                    .at_css("input[value='junction.codes/components.all.read']")

      expect(box["data-initial"]).to eq("true")
    end

    it "marks an access level nothing registers for a context" do
      marks = response.parsed_body.css(".sr-only").map(&:text)

      expect(marks).to include("Permission not registered")
    end

    it "says how much of what could be granted is" do
      expect(response.body).to match(/of #{Junction::PluginRegistry.permissions.size} selected/)
    end

    it "lists the pending changes beside the form" do
      expect(response.body).to include("Unsaved changes")
    end

    it "cannot be saved until something changes" do
      save = response.parsed_body.at_css("button[type='submit']")

      expect(save.attributes).to have_key("disabled")
    end

    it "says what each permission allows" do
      described = Junction::PluginRegistry.permissions
                                          .find { |permission| permission.description.present? }

      expect(response.body).to include(described.description)
    end
  end

  describe "the editor for a system role" do
    let(:admin) do
      Junction::Role.find_by(name: Junction::Role::ADMIN_NAME) ||
        create(:role, :system, name: Junction::Role::ADMIN_NAME)
    end

    before do
      sign_in_user_with_permissions(%w[
        junction.codes/roles.all.read junction.codes/roles.all.write
      ])

      get edit_role_path(namespace: admin.namespace, name: admin.name)
    end

    it "ticks what the role resolves to" do
      box = response.parsed_body
                    .at_css("input[value='junction.codes/components.all.read']")

      expect(box.attributes).to have_key("checked")
    end

    it "does not offer to change them" do
      boxes = response.parsed_body.css("input[name*='permission_ids']")

      expect(boxes).to all(have_attributes(attributes: hash_including("disabled")))
    end

    it "says why" do
      expect(response.body).to include("cannot be edited")
    end

    it "does not invite an edit it would discard" do
      expect(response.body).to include("What it grants is resolved")
    end
  end

  describe "saving a role that holds an unregistered permission" do
    let(:held) { create(:role) }
    let(:stale) { "acme.io/widgets.all.read" }

    before do
      sign_in_user_with_permissions(%w[
        junction.codes/roles.all.read junction.codes/roles.all.write
      ])

      held.role_permissions.create!(permission: stale)
      held.role_permissions.create!(permission: "junction.codes/components.all.read")
    end

    it "keeps the permission the form never offered" do
      patch role_url(held), params: { role: { permission_ids: [] } }

      expect(held.role_permissions.pluck(:permission)).to eq([ stale ])
    end

    it "still removes the permissions that were cleared" do
      patch role_url(held), params: { role: { permission_ids: [] } }

      expect(held.role_permissions.pluck(:permission))
        .not_to include("junction.codes/components.all.read")
    end

    it "refuses a permission nothing registers" do
      patch role_url(held), params: { role: { permission_ids: [ "acme.io/secrets.all.destroy" ] } }

      expect(held.role_permissions.pluck(:permission))
        .not_to include("acme.io/secrets.all.destroy")
    end

    it "still grants the registered permissions sent with it" do
      patch role_url(held), params: {
        role: { permission_ids: [ "acme.io/secrets.all.destroy",
                                  "junction.codes/apis.all.read" ] }
      }

      expect(held.role_permissions.pluck(:permission))
        .to include("junction.codes/apis.all.read")
    end
  end

  describe "a save the role rejects" do
    let(:granted) { create(:role, title: "Service Owner") }
    let(:group) { create(:group) }

    before do
      sign_in_user_with_permissions(%w[
        junction.codes/roles.all.read junction.codes/roles.all.write
      ])

      group.roles = [ granted ]
      create(:group_membership, group:)

      patch role_url(granted), params: { role: { title: "", description: "" } }
    end

    it "names the role as it is stored" do
      expect(response.parsed_body.at_css("h1").text).to include("Service Owner")
    end

    it "still counts the groups holding it" do
      groups = response.parsed_body.css("dt").find { |term| term.text == "Groups" }

      expect(groups.next_element.text).to eq("1")
    end

    it "still counts the people it reaches" do
      people = response.parsed_body.css("dt").find { |term| term.text == "People" }

      expect(people.next_element.text).to eq("1")
    end
  end

  describe "the permissions a rejected save sent" do
    let(:edited) { create(:role, title: "Service Owner") }
    let(:added) { "junction.codes/apis.all.read" }

    before do
      sign_in_user_with_permissions(%w[
        junction.codes/roles.all.read junction.codes/roles.all.write
      ])
    end

    def box(permission)
      response.parsed_body.at_css("input[value='#{permission}']")
    end

    context "when the role already exists" do
      before do
        patch role_url(edited), params: {
          role: { title: "", description: "", permission_ids: [ added ] }
        }
      end

      it "ticks them again" do
        expect(box(added).attributes).to have_key("checked")
      end

      it "still counts them as pending" do
        expect(box(added)["data-initial"]).to eq("false")
      end
    end

    context "when the role is being created" do
      before do
        post roles_url, params: {
          role: { title: "", description: "", permission_ids: [ added ] }
        }
      end

      it "ticks them again" do
        expect(box(added).attributes).to have_key("checked")
      end
    end

    context "when every permission was cleared" do
      before do
        edited.role_permissions.create!(permission: added)

        patch role_url(edited), params: { role: { title: "", description: "" } }
      end

      it "leaves them cleared" do
        expect(box(added).attributes).not_to have_key("checked")
      end

      it "counts the removal as pending" do
        expect(box(added)["data-initial"]).to eq("true")
      end
    end
  end
end
