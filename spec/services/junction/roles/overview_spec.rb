# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Roles::Overview do
  subject(:overview) { described_class.new }

  # The seeds and other specs may have made the system roles already, so this
  # takes whichever admin exists rather than insisting on making one.
  def admin_role
    Junction::Role.find_by(name: Junction::Role::ADMIN_NAME) ||
      create(:role, name: Junction::Role::ADMIN_NAME, title: "Admin",
                    system_role: true)
  end

  describe "#roles" do
    before { admin_role }

    it "lists a system role as one the engine ships" do
      expect(overview.system_roles.map(&:title)).to include("Admin")
    end

    it "keeps it out of the roles this catalog defined" do
      expect(overview.custom_roles.map(&:title)).not_to include("Admin")
    end

    it "addresses a role's pane by namespace and name" do
      expect(described_class.pane_id(admin_role)).to eq("default-admin")
    end

    it "counts what a system role actually grants" do
      admin = overview.roles.find { |role| role.title == "Admin" }

      expect(admin.permissions).to eq(Junction::PluginRegistry.permissions.size)
    end
  end

  describe "#detail" do
    let(:role) { create(:role) }

    before do
      role.role_permissions.create!(permission: "junction.codes/components.owned.write")
      role.role_permissions.create!(permission: "junction.codes/components.all.read")
    end

    def cell(context, access)
      row = overview.detail(role).fetch(:matrix).find { |r| r[:context] == context }
      row && row[access]
    end

    it "reports the widest scope a role holds at an access level" do
      expect(cell("junction.codes/components", :read)).to eq("all")
    end

    it "reports a narrower scope where that is all the role holds" do
      expect(cell("junction.codes/components", :write)).to eq("owned")
    end

    it "marks a permission the role could hold and does not" do
      expect(cell("junction.codes/components", :destroy))
        .to eq(described_class::NOT_GRANTED)
    end

    it "marks a permission nothing registers" do
      row = overview.detail(admin_role).fetch(:matrix)
                    .find { |r| r[:context] == "junction.codes/annotations" }

      expect(row[:write]).to eq(described_class::NOT_REGISTERED)
    end
  end

  describe "a role holding a permission nothing registers" do
    let(:role) { create(:role) }

    before do
      role.role_permissions.create!(permission: "junction.codes/components.all.read")
      role.role_permissions.create!(permission: "removed.plugin/widgets.all.read")
    end

    it "leaves it out of what the role grants" do
      expect(overview.detail(role).fetch(:permissions))
        .to eq([ "junction.codes/components.all.read" ])
    end

    it "leaves it out of the count the index shows" do
      summary = overview.roles.find { |candidate| candidate.record == role }

      expect(summary.permissions).to eq(1)
    end
  end

  describe "the people a role reaches" do
    let(:role) { create(:role) }
    let(:parent) { create(:group) }
    let(:child) { create(:group, parent:) }

    before do
      parent.roles << role
      create(:group_membership, group: parent, user: create(:user))
      create(:group_membership, group: child, user: create(:user))
    end

    it "counts the members of the groups beneath the one granted" do
      expect(overview.detail(role).fetch(:people)).to eq(2)
    end

    it "counts somebody in two of those groups once" do
      shared = create(:user)
      create(:group_membership, group: parent, user: shared)
      create(:group_membership, group: child, user: shared)

      expect(overview.detail(role).fetch(:people)).to eq(3)
    end
  end
end
