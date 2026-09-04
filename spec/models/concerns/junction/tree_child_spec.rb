# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::TreeChild do
  let(:group) { create(:group) }

  describe "parent kind" do
    it "rejects a parent of another kind" do
      domain = build(:domain, owner: group)
      domain.parent_id = create(:group).id

      expect(domain).not_to be_valid
    end

    it "reports the problem on parent_id" do
      domain = build(:domain, owner: group)
      domain.parent_id = create(:group).id
      domain.valid?

      expect(domain.errors[:parent_id]).to be_present
    end

    it "accepts a parent of the same kind" do
      expect(build(:domain, owner: group, parent: create(:domain, owner: group))).to be_valid
    end

    it "accepts no parent" do
      expect(build(:domain, owner: group, parent: nil)).to be_valid
    end
  end

  describe "cycles" do
    it "rejects an entity as its own parent" do
      domain = create(:domain, owner: group)
      domain.parent_id = domain.id

      expect(domain).not_to be_valid
    end

    it "rejects a descendant as a parent" do
      parent = create(:domain, owner: group)
      child = create(:domain, owner: group, parent:)
      parent.parent = child

      expect(parent).not_to be_valid
    end
  end
end
