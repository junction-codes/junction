# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Taggable do
  subject(:component) { build(:component) }

  describe "tags" do
    it "defaults to none" do
      expect(component.tags).to eq([])
    end

    it "keeps a list" do
      component.tags = %w[portal java]
      expect(component.tags).to eq(%w[portal java])
    end

    it "accepts a comma-separated string" do
      component.tags = "portal, java"
      expect(component.tags).to eq(%w[portal java])
    end

    it "lowercases them" do
      component.tags = %w[Portal JAVA]
      expect(component.tags).to eq(%w[portal java])
    end

    it "discards duplicates" do
      component.tags = %w[portal portal]
      expect(component.tags).to eq(%w[portal])
    end

    it "discards blanks" do
      component.tags = [ "portal", "", "  " ]
      expect(component.tags).to eq(%w[portal])
    end

    it "treats nil as none" do
      component.tags = nil
      expect(component.tags).to eq([])
    end

    it "rejects a tag that does not match the expected format" do
      component.tags = [ "not a tag" ]
      expect(component).not_to be_valid
    end

    it "rejects a tag longer than 63 characters" do
      component.tags = [ "a" * 64 ]
      expect(component).not_to be_valid
    end

    it "accepts the punctuation Backstage allows" do
      component.tags = %w[c++ dot.net my-tag]
      expect(component).to be_valid
    end
  end

  describe "labels" do
    it "defaults to none" do
      expect(component.labels).to eq({})
    end

    it "keeps a key/value pair" do
      component.labels = { "tier" => "gold" }
      expect(component.labels).to eq({ "tier" => "gold" })
    end

    it "stringifies keys and values" do
      component.labels = { tier: 1 }
      expect(component.labels).to eq({ "tier" => "1" })
    end

    it "discards a row with a blank key" do
      component.labels = { "" => "orphan", "tier" => "gold" }
      expect(component.labels).to eq({ "tier" => "gold" })
    end

    it "treats nil as none" do
      component.labels = nil
      expect(component.labels).to eq({})
    end
  end

  describe "scopes" do
    let(:group) { create(:group) }

    before do
      create(:component, name: "tagged-both", owner: group, tags: %w[portal java])
      create(:component, name: "tagged-one", owner: group, tags: %w[portal])
      create(:component, name: "tagged-none", owner: group)
    end

    it "matches entities carrying every tag" do
      expect(Junction::Component.tagged_with("portal", "java").pluck(:name))
        .to contain_exactly("tagged-both")
    end

    it "matches entities carrying any tag" do
      expect(Junction::Component.tagged_with_any("java", "missing").pluck(:name))
        .to contain_exactly("tagged-both")
    end

    it "matches on a single shared tag" do
      expect(Junction::Component.tagged_with("portal").pluck(:name))
        .to contain_exactly("tagged-both", "tagged-one")
    end
  end

  describe "persistence" do
    it "round-trips tags and labels" do
      component.tags = %w[portal]
      component.labels = { "tier" => "gold" }
      component.save!

      expect(component.reload.attributes.values_at("tags", "labels"))
        .to eq([ %w[portal], { "tier" => "gold" } ])
    end
  end
end
