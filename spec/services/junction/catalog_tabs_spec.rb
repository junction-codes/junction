# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::CatalogTabs do
  subject(:tabs) { described_class.new(relation:, kind:, user:) }

  let(:relation) { Junction::Component.where(title: %w[ours theirs]) }
  let(:kind) { Junction::Kinds.by_scope(:component) }
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  describe "#names" do
    it "offers every tab to a kind that is owned and has a lifecycle" do
      expect(tabs.names).to eq(%w[all mine production recent])
    end

    context "with a kind that shows no lifecycle" do
      let(:relation) { Junction::Group.where(title: "irrelevant") }
      let(:kind) { Junction::Kinds.by_scope(:group) }

      it "leaves out the production tab" do
        expect(tabs.names).not_to include("production")
      end
    end

    context "with nobody signed in" do
      let(:user) { nil }

      it "leaves out the tabs that are about the viewer" do
        expect(tabs.names).to eq(%w[all production recent])
      end
    end

    context "with a viewer who owns nothing at all" do
      let(:user) { build(:user) }

      it "leaves out the mine tab" do
        expect(tabs.names).not_to include("mine")
      end
    end
  end

  describe "#scope" do
    before do
      create(:group_membership, user:, group:)
      create(:component, title: "ours", owner: group, lifecycle: "production")
      create(:component, title: "theirs", lifecycle: "experimental")
    end

    it "narrows to what the viewer's groups own" do
      expect(tabs.scope("mine").pluck(:title)).to contain_exactly("ours")
    end

    it "narrows to production" do
      expect(tabs.scope("production").pluck(:title)).to contain_exactly("ours")
    end

    it "leaves the relation alone for a sort-only tab" do
      expect(tabs.scope("recent").count).to eq(relation.count)
    end

    it "falls back to everything for an unknown tab" do
      expect(tabs.scope("../../etc/passwd").count).to eq(relation.count)
    end
  end

  describe "#sorts" do
    it "sorts the recent tab by when things changed" do
      expect(tabs.sorts("recent")).to eq("updated_at desc")
    end

    it "leaves the other tabs to the listing's own sort" do
      expect(tabs.sorts("mine")).to be_nil
    end
  end

  describe "#counts" do
    before do
      create(:group_membership, user:, group:)
      create(:component, title: "ours", owner: group, lifecycle: "production")
      create(:component, title: "theirs", lifecycle: "experimental")
    end

    it "counts each tab" do
      expect(tabs.counts).to eq("all" => 2, "mine" => 1, "production" => 1)
    end

    it "asks the database once" do
      expect { tabs.counts }.to make_database_queries(count: 1,
                                                      matching: /COUNT\(\*\)/)
    end

    it "leaves out the tab that has no count" do
      expect(tabs.counts).not_to have_key("recent")
    end
  end

  describe "#counts when the viewer owns nothing at all" do
    let(:user) { build(:user) }

    before { create(:component, title: "ours") }

    # Not zero: the tab is not on offer, so nothing asks the database about it.
    it "does not count a tab it does not offer" do
      expect(tabs.counts).not_to have_key("mine")
    end

    it "still counts everything in the relation" do
      expect(tabs.counts["all"]).to eq(1)
    end
  end

  describe "#implied_filter" do
    it "gives the production tab its lifecycle" do
      expect(tabs.implied_filter("production"))
        .to eq([ "lifecycle_eq", "production" ])
    end

    it "marks the mine tab as having no single value" do
      expect(tabs.implied_filter("mine")).to eq([ "owner_id_eq", :viewer ])
    end

    it "gives nothing to a tab that filters nothing" do
      expect(tabs.implied_filter("all")).to be_nil
    end

    it "gives nothing to a tab that only sorts" do
      expect(tabs.implied_filter("recent")).to be_nil
    end

    it "gives nothing for a tab this listing does not offer" do
      expect(tabs.implied_filter("nonsense")).to be_nil
    end
  end

  describe "#resolve" do
    it "keeps a tab the listing offers" do
      expect(tabs.resolve("mine")).to eq("mine")
    end

    it "falls back for one it does not" do
      expect(tabs.resolve("nonsense")).to eq("all")
    end
  end
end
