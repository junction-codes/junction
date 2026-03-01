# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::User, type: :model do
  describe "validations" do
    subject(:user) { build(:user) }

    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it_behaves_like "validates presence of", :display_name
    it_behaves_like "validates email format of", :email_address, required: true
    it_behaves_like "validates presence of", :email_address
    it_behaves_like "validates uniqueness of", :email_address, "duplicate@example.com"
    it_behaves_like "validates presence of", :password
    it_behaves_like "validates image_url format"

    context "when the password is too short" do
      before { user.password = user.password_confirmation = "short" }

      it "is invalid" do
        expect(user).not_to be_valid
      end

      it "includes length error for password" do
        user.valid?
        expect(user.errors[:password]).to include("is too short (minimum is 8 characters)")
      end
    end

    context "when the password confirmation does not match" do
      before { user.password_confirmation = "mismatch" }

      it "is invalid" do
        user.password_confirmation = "wrong_password"
        expect(user).not_to be_valid
      end

      it "includes confirmation error for password_confirmation" do
        user.valid?
        expect(user.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end

    it "is valid when updating attributes without changing the password" do
      user.save!
      user.display_name = "New Name"
      expect(user).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:group_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:group_memberships) }
  end

  describe "normalizations" do
    it "downcases and strips the email address before validation" do
      user = build(:user, email_address: "  TEST@EXAMPLE.COM  ")
      user.valid?
      expect(user.email_address).to eq("test@example.com")
    end
  end

  describe "#deep_group_ids" do
    it "returns ids of all groups the user is a member of, including ancestors" do
      grandparent = create(:group)
      parent = create(:group, parent: grandparent)
      child = create(:group, parent: parent)
      user = create(:user, groups: [ child ])

      expect(user.deep_group_ids).to contain_exactly(child.id, parent.id, grandparent.id)
    end
  end

  describe "#components" do
    let(:grandparent) { create(:group) }
    let(:parent) { create(:group, parent: grandparent) }
    let(:child) { create(:group, parent: parent) }
    let!(:components) do
      [ child, parent, grandparent ].map { |owner| create(:component, owner:) }
    end

    it "returns components owned by the user's groups and their ancestors" do
      user = create(:user, groups: [ child ])
      create(:component)

      expect(user.components).to match_array(components)
    end
  end

  describe "#systems" do
    let(:grandparent) { create(:group) }
    let(:parent) { create(:group, parent: grandparent) }
    let(:child) { create(:group, parent: parent) }
    let!(:systems) do
      [ child, parent, grandparent ].map { |owner| create(:system, owner:) }
    end

    it "returns systems owned by the user's groups and their ancestors" do
      user = create(:user, groups: [ child ])
      create(:system)

      expect(user.systems).to match_array(systems)
    end
  end
end
