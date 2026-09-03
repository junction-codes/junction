# frozen_string_literal: true

require "rails_helper"

# Auth principals and RBAC configuration used to be unreachable from catalog
# queries because they lived in their own tables. Now that every kind shares
# junction_entities, that isolation is enforced in code, so it needs guarding.
RSpec.describe "entity isolation", type: :request do
  include AuthenticationHelper

  requires_authentication

  describe "global search" do
    before do
      create(:user, title: "Findable Person")
      create(:group, title: "Findable Team")
      create(:role, title: "Findable Role")
      create(:component, title: "Findable Component", owner: junction_groups(:group_one))

      get search_path, params: { q: "Findable" }
    end

    it "returns catalog entities" do
      expect(response.body).to include("Findable Component")
    end

    it "does not leak users" do
      expect(response.body).not_to include("Findable Person")
    end

    it "does not leak groups" do
      expect(response.body).not_to include("Findable Team")
    end

    it "does not leak roles" do
      expect(response.body).not_to include("Findable Role")
    end
  end

  describe "search autocomplete" do
    before do
      create(:user, title: "Autocomplete Person")
      get search_autocomplete_path, params: { q: "Autocomplete" }
    end

    it "does not leak users" do
      expect(response.body).not_to include("Autocomplete Person")
    end
  end

  describe "POST /users" do
    let(:params) do
      {
        user: {
          title: "New Person",
          email: "new-person@example.com",
          email_confirmation: "new-person@example.com",
          password: "passWord1!",
          password_confirmation: "passWord1!",
          owner_id: junction_groups(:group_one).id,
          kind: "Component"
        }
      }
    end

    it "creates the user" do
      expect { post users_path, params: params }.to change(Junction::User, :count).by(1)
    end

    it "ignores an owner_id, which would otherwise grant owned access to the account" do
      post users_path, params: params
      expect(Junction::User.find_by(email: "new-person@example.com").owner_id).to be_nil
    end

    it "ignores an attempt to set the kind" do
      post users_path, params: params
      expect(Junction::User.find_by(email: "new-person@example.com").kind).to eq("User")
    end
  end

  describe "credentials" do
    it "exposes no queryable attributes" do
      expect(Junction::Credential.ransackable_attributes).to be_empty
    end

    it "exposes no queryable associations" do
      expect(Junction::Credential.ransackable_associations).to be_empty
    end

    it "keeps the digest off the entity table" do
      expect(Junction::Entity.column_names).not_to include("password_digest")
    end
  end

  describe "role grants" do
    it "cannot be set through the group form without role write access" do
      sign_in_user_with_permissions(%w[
        junction.codes/groups.all.read junction.codes/groups.all.write
      ])
      group = create(:group)
      role = create(:role)

      patch group_path(namespace: group.namespace, name: group.name),
            params: { group: { title: group.title, role_ids: [ role.id ] } }

      expect(group.reload.roles).to be_empty
    end

    it "is not reachable through a group annotation" do
      group = create(:group, annotations: { "junction.codes/role" => "admin" })
      expect(group.reload.roles).to be_empty
    end
  end
end
