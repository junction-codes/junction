# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::ApplicationPolicy, type: :policy do
  subject(:policy) { Junction::RolePolicy.new(entity, user:) }

  let(:entity) { build_stubbed(:role) }
  let(:permission_strings) { [] }
  let(:user_groups) { [ 99, 100 ] }
  let(:user_permissions) do
    instance_double(Junction::Permissions::UserPermissions, has_permission?: false)
  end

  let(:user) do
    build_stubbed(:user) do |u|
      allow(u).to receive(:deep_group_ids).and_return(user_groups)
    end
  end

  before do
    allow(Junction::Permissions::UserPermissions).to receive(:new)
      .with(user).and_return(user_permissions)

    permission_strings.each do |permission_string|
      allow(user_permissions).to receive(:has_permission?)
        .with(permission_string).and_return(true)
    end
  end

  describe "#context" do
    it "is implemented by the subclass" do
      expect(policy.context).to eq("roles")
    end
  end

  describe "#allowed_permission?" do
    context "when the user does not have the requested permission" do
      it "returns false" do
        expect(policy.allowed_permission?("junction.codes/roles.all.read")).to be(false)
      end
    end

    context "when the user has the requested permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.read" ] }

      it "returns true when no entity is given" do
        expect(policy.allowed_permission?(permission_strings.first)).to be(true)
      end

      it "returns true when entity is nil" do
        expect(policy.allowed_permission?(permission_strings.first, entity:)).to be(true)
      end

      context "when the entity has no owner_id" do
        subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

        let(:permission_strings) { [ "junction.codes/components.all.read" ] }
        let(:entity) { build_stubbed(:component, owner_id: nil) }

        it "returns true" do
          expect(policy.allowed_permission?(permission_strings.first, entity:)).to be(true)
        end
      end

      context "when the entity has an owner_id in the user's group hierarchy" do
        subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

        let(:permission_strings) { [ "junction.codes/components.owned.read" ] }
        let(:entity) { build_stubbed(:component, owner_id: 99) }

        it "returns true for an owned permission when user owns the entity" do
          expect(policy.allowed_permission?(permission_strings.first, entity:)).to be(true)
        end
      end

      context "when the entity has an owner_id not in the user's group hierarchy" do
        subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

        let(:permission_strings) { [ "junction.codes/components.owned.read" ] }
        let(:entity) { build_stubbed(:component, owner_id: 999) }

        it "returns false for an owned permission" do
          expect(policy.allowed_permission?(permission_strings.first, entity:)).to be(false)
        end
      end
    end
  end

  describe "#allowed_access?" do
    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.read" ] }

      it "access is granted" do
        expect(policy.allowed_access?(Junction::Permission::Access::READ)).to be(true)
      end
    end

    context "when the user has the owned permission" do
      subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

      let(:permission_strings) { [ "junction.codes/components.owned.read" ] }
      let(:entity) { build_stubbed(:component, owner_id: 99) }

      context "when the user owns the entity" do
        let(:user_groups) { [ 99 ] }

        it "access is granted" do
          expect(policy.allowed_access?(Junction::Permission::Access::READ, entity:)).to be(true)
        end
      end

      context "when the user does not own the entity" do
        let(:user_groups) { [ 999 ] }

        it "access is denied" do
          expect(policy.allowed_access?(Junction::Permission::Access::READ, entity:)).to be(false)
        end
      end
    end

    context "when the user does not have a required permission" do
      it "access is denied" do
        expect(policy.allowed_access?(Junction::Permission::Access::READ)).to be(false)
      end
    end
  end

  describe "#index?" do
    subject(:policy) { Junction::RolePolicy.new(Junction::Component, user:) }

    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.read" ] }

      it "access is granted" do
        expect(policy.index?).to be(true)
      end
    end

    context "when the user has the owned permission" do
      subject(:policy) { Junction::ComponentPolicy.new(Junction::Component, user:) }

      let(:permission_strings) { [ "junction.codes/components.owned.read" ] }

      it "access is granted" do
        expect(policy.index?).to be(true)
      end
    end

    context "when the user does not have a required permission" do
      it "access is denied" do
        expect(policy.index?).to be(false)
      end
    end
  end

  describe "#index_all?" do
    subject(:policy) { Junction::ComponentPolicy.new(Junction::Component, user:) }

    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/components.all.read" ] }

      it "access is granted" do
        expect(policy.index_all?).to be(true)
      end
    end

    context "when the user only has the owned permission" do
      let(:permission_strings) { [ "junction.codes/components.owned.read" ] }

      it "access is denied" do
        expect(policy.index_all?).to be(false)
      end
    end

    context "when the user has neither permission" do
      it "access is denied" do
        expect(policy.index_all?).to be(false)
      end
    end
  end

  describe "#index_owned?" do
    subject(:policy) { Junction::ComponentPolicy.new(Junction::Component, user:) }

    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/components.all.read" ] }

      it "access is denied" do
        expect(policy.index_owned?).to be(false)
      end
    end

    context "when the user has the owned permission" do
      let(:permission_strings) { [ "junction.codes/components.owned.read" ] }

      it "access is granted" do
        expect(policy.index_owned?).to be(true)
      end
    end

    context "when the user has neither permission" do
      it "access is denied" do
        expect(policy.index_owned?).to be(false)
      end
    end
  end

  describe "#show?" do
    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.read" ] }

      it "access is granted" do
        expect(policy.show?).to be(true)
      end
    end

    context "when the user has the owned permission" do
      subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

      let(:permission_strings) { [ "junction.codes/components.owned.read" ] }
      let(:entity) { build_stubbed(:component, owner_id: 99) }

      context "when the user owns the entity" do
        let(:user_groups) { [ 99 ] }

        it "access is granted" do
          expect(policy.show?).to be(true)
        end
      end

      context "when the user does not own the entity" do
        let(:user_groups) { [ 999 ] }

        it "access is denied" do
          expect(policy.show?).to be(false)
        end
      end
    end

    context "when the user does not have a required permission" do
      it "access is denied" do
        expect(policy.show?).to be(false)
      end
    end
  end

  describe "#create?" do
    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.write" ] }

      it "access is granted" do
        expect(policy.create?).to be(true)
      end
    end

    context "when the user has the owned permission" do
      let(:permission_strings) { [ "junction.codes/roles.owned.write" ] }

      it "access is granted" do
        expect(policy.create?).to be(true)
      end
    end

    context "when the user does not have a required permission" do
      it "access is denied" do
        expect(policy.create?).to be(false)
      end
    end
  end

  describe "#create_all?" do
    subject(:policy) { Junction::ComponentPolicy.new(Junction::Component, user:) }

    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/components.all.write" ] }

      it "access is granted" do
        expect(policy.create_all?).to be(true)
      end
    end

    context "when the user only has the owned permission" do
      let(:permission_strings) { [ "junction.codes/components.owned.write" ] }

      it "access is denied" do
        expect(policy.create_all?).to be(false)
      end
    end

    context "when the user has neither permission" do
      it "access is denied" do
        expect(policy.create_all?).to be(false)
      end
    end
  end

  describe "#create_owned?" do
    subject(:policy) { Junction::ComponentPolicy.new(Junction::Component, user:) }

    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/components.all.write" ] }

      it "access is denied" do
        expect(policy.create_owned?).to be(false)
      end
    end

    context "when the user has the owned permission" do
      let(:permission_strings) { [ "junction.codes/components.owned.write" ] }

      it "access is granted" do
        expect(policy.create_owned?).to be(true)
      end
    end

    context "when the user has neither permission" do
      it "access is denied" do
        expect(policy.create_owned?).to be(false)
      end
    end
  end

  describe "#update?" do
    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.write" ] }

      it "access is granted" do
        expect(policy.update?).to be(true)
      end
    end

    context "when the user has the owned permission" do
      subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

      let(:permission_strings) { [ "junction.codes/components.owned.write" ] }
      let(:entity) { build_stubbed(:component, owner_id: 99) }

      context "when the user owns the entity" do
        let(:user_groups) { [ 99 ] }

        it "access is granted" do
          expect(policy.update?).to be(true)
        end
      end

      context "when the user does not own the entity" do
        let(:user_groups) { [ 999 ] }

        it "access is denied" do
          expect(policy.update?).to be(false)
        end
      end
    end

    context "when the user does not have a required permission" do
      it "access is denied" do
        expect(policy.update?).to be(false)
      end
    end
  end

  describe "#destroy?" do
    context "when the user has the all permission" do
      let(:permission_strings) { [ "junction.codes/roles.all.destroy" ] }

      it "access is granted" do
        expect(policy.destroy?).to be(true)
      end
    end

    context "when the user has the owned permission" do
      subject(:policy) { Junction::ComponentPolicy.new(entity, user:) }

      let(:permission_strings) { [ "junction.codes/components.owned.destroy" ] }
      let(:entity) { build_stubbed(:component, owner_id: 99) }

      context "when the user owns the entity" do
        let(:user_groups) { [ 99 ] }

        it "access is granted" do
          expect(policy.destroy?).to be(true)
        end
      end

      context "when the user does not own the entity" do
        let(:user_groups) { [ 999 ] }

        it "access is denied" do
          expect(policy.destroy?).to be(false)
        end
      end
    end

    context "when the user does not have a required permission" do
      it "access is denied" do
        expect(policy.destroy?).to be(false)
      end
    end
  end
end
