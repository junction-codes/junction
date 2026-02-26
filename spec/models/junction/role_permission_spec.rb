# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::RolePermission, type: :model do
  describe "validations" do
    subject(:role_permission) { build(:role_permission, role: create(:role)) }

    it "is valid with valid attributes" do
      expect(role_permission).to be_valid
    end

    it_behaves_like "validates presence of", :permission
    it_behaves_like "validates uniqueness of", :permission, "junction/codes.all.read", scope: :role_id
  end

  describe "uniqueness scope" do
    it "allows the same permission for different roles" do
      roles = 2.times.map { create(:role) }
      create(:role_permission, role: roles[0], permission: "junction/codes.all.read")
      second = build(:role_permission, role: roles[1], permission: "junction/codes.all.read")

      expect(second).to be_valid
    end

    it "does not allow the same permission for the same role" do
      role = create(:role)
      create(:role_permission, role:, permission: "junction/codes.all.read")
      second = build(:role_permission, role:, permission: "junction/codes.all.read")

      expect(second).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:role).class_name("Junction::Role") }
  end

  describe ".ransackable_attributes" do
    it "returns permission" do
      expect(described_class.ransackable_attributes).to eq(%w[permission])
    end
  end
end
