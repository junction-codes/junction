# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Role, type: :model do
  subject(:role) { build(:role, system:) }

  let(:system) { false }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(role).to be_valid
    end

    it_behaves_like "validates presence of", :description
    it_behaves_like "validates presence of", :name
    it_behaves_like "validates uniqueness of", :name, "Duplicate Role"
  end

  describe "associations" do
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:role_permissions).dependent(:destroy) }
  end

  describe "#permission_strings" do
    it "returns permission strings in order" do
      %w[zebra alpha beta].each do |permission|
        create(:role_permission, role:, permission: "junction.codes/#{permission}.all.read")
      end

      expect(role.permission_strings).to eq(
        %w[junction.codes/alpha.all.read junction.codes/beta.all.read junction.codes/zebra.all.read]
      )
    end

    it "returns an empty array when the role has no permissions" do
      expect(role.permission_strings).to eq([])
    end
  end

  describe "#system?" do
    context "when the role is a system role" do
      let(:system) { true }

      it "returns true" do
        expect(role).to be_system
      end
    end

    context "when the role is not a system role" do
      it "returns false" do
        expect(role).not_to be_system
      end
    end
  end

  describe "#destroy" do
    before { role.save }

    context "when the role is not a system role" do
      it "allows destroying the role" do
        expect { role.destroy }.to change(described_class, :count).by(-1)
      end
    end

    context "when the role is a system role" do
      let(:system) { true }

      it "refuses to destroy the role" do
        expect { role.destroy }.not_to change(described_class, :count)
      end

      it "returns false" do
        expect(role.destroy).to be(false)
      end
    end
  end

  describe ".ransackable_associations" do
    it "returns role_permissions" do
      expect(described_class.ransackable_associations).to eq(%w[role_permissions])
    end
  end

  describe ".ransackable_attributes" do
    it "returns description and name" do
      expect(described_class.ransackable_attributes).to eq(%w[description name])
    end
  end
end
