# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Permissions::UserPermissions do
  subject(:user_permissions) { described_class.new(user) }

  let(:user) { create(:user) }
  let(:permissions) { [ "junction.codes/apis.all.read", "junction.codes/apis.owned.write" ] }

  describe "#permission_set" do
    context "when there is no current user" do
      let(:user) { nil }

      it "returns an empty set" do
        expect(user_permissions.permission_set).to eq(Set.new)
      end
    end

    context "when the user is not a member of any groups" do
      it "returns an empty set" do
        expect(user_permissions.permission_set).to eq(Set.new)
      end
    end

    context "when the user's groups have no roles" do
      before { create(:group_membership, user:, group: create(:group)) }

      it "returns an empty set" do
        expect(user_permissions.permission_set).to eq(Set.new)
      end
    end

    context "when the user's direct group has a role with permissions" do
      let(:group) { create(:group, annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => role.name }) }
      let(:role) { create(:role, name: "Custom Role", permissions:) }

      before { user.update!(groups: [ group ]) }

      it "returns the role's permission strings" do
        expect(user_permissions.permission_set).to eq(permissions.to_set)
      end
    end

    context "when the user's ancestor group has a role with permissions" do
      let(:parent) { create(:group, annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => role.name }) }
      let(:child) { create(:group, parent: parent) }
      let(:role) { create(:role, name: "Ancestor Role", permissions: [ permissions.last ]) }

      before { user.update!(groups: [ child ]) }

      it "includes permissions from the ancestor group's role" do
        expect(user_permissions.permission_set).to eq(Set[permissions.last])
      end
    end

    context "when the user's group has the Admin role" do
      let(:role) { Junction::Role.find_by(name: described_class::ADMIN_ROLE_NAME) }
      let(:group) { create(:group, annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => role.name }) }

      before do
        user.update!(groups: [ group ])
        allow(Junction::PluginRegistry).to receive(:permissions)
          .and_return(permissions.map { |permission| Junction::Permission.parse(permission) })
      end

      it "returns all registry permissions" do
        expect(user_permissions.permission_set).to eq(permissions.to_set)
      end
    end

    context "when the user's group has the read all role" do
      let(:role) { Junction::Role.find_by(name: described_class::READ_ALL_ROLE_NAME) }
      let(:group) { create(:group, annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => role.name }) }

      before do
        user.update!(groups: [ group ])
        allow(Junction::PluginRegistry).to receive(:permissions)
          .and_return(permissions.map { |permission| Junction::Permission.parse(permission) })
      end

      it "returns only read permissions from the registry" do
        expect(user_permissions.permission_set).to eq(Set[permissions.first])
      end
    end
  end

  describe "#has_permission?" do
    context "when there is no current user" do
      let(:user) { nil }

      it "returns false" do
        expect(user_permissions.has_permission?(permissions.first)).to be(false)
      end
    end

    context "when the user has the permission" do
      let(:role) { create(:role, name: "Test Role", permissions: [ permissions.first ]) }
      let(:group) { create(:group, annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => role.name }) }

      before { user.update!(groups: [ group ]) }

      it "returns true for a string permission" do
        expect(user_permissions.has_permission?(permissions.first)).to be(true)
      end

      it "returns true for a permission object" do
        expect(user_permissions.has_permission?(Junction::Permission.parse(permissions.first))).to be(true)
      end
    end

    context "when the user does not have the permission" do
      it "returns false" do
        expect(user_permissions.has_permission?(permissions.last)).to be(false)
      end
    end
  end
end
