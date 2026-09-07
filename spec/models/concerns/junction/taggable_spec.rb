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

    it "accepts the punctuation allowed" do
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

  describe "label rows" do
    it "offers a blank row when there are no labels" do
      expect(component.label_rows).to eq([ { key: "", value: "" } ])
    end

    it "lists a row per label, then a blank one to fill in" do
      component.labels = { "tier" => "gold" }

      expect(component.label_rows)
        .to eq([ { key: "tier", value: "gold" }, { key: "", value: "" } ])
    end

    it "does not add a second blank row when one is already there" do
      component.labels = { "" => "" }

      expect(component.label_rows.count { |row| row[:key].blank? }).to eq(1)
    end

    it "builds labels from form rows" do
      component.label_rows = {
        "0" => { "key" => "tier", "value" => "gold" },
        "1" => { "key" => "runtime", "value" => "go1.22" }
      }
      component.validate

      expect(component.labels).to eq({ "tier" => "gold", "runtime" => "go1.22" })
    end

    it "accepts rows as an array" do
      component.label_rows = [ { key: "tier", value: "gold" } ]
      component.validate

      expect(component.labels).to eq({ "tier" => "gold" })
    end

    it "discards a row with a blank key" do
      component.label_rows = [ { key: "", value: "orphan" },
                               { key: "tier", value: "gold" } ]
      component.validate

      expect(component.labels).to eq({ "tier" => "gold" })
    end

    it "trims whitespace around the key" do
      component.label_rows = [ { key: "  tier  ", value: "gold" } ]
      component.validate

      expect(component.labels).to eq({ "tier" => "gold" })
    end

    it "clears the labels when every row is removed" do
      component.labels = { "tier" => "gold" }
      component.label_rows = []
      component.validate

      expect(component.labels).to eq({})
    end

    it "leaves the labels alone when no rows are submitted" do
      component.labels = { "tier" => "gold" }
      component.validate

      expect(component.labels).to eq({ "tier" => "gold" })
    end

    it "does not re-apply the rows on a later save" do
      component.label_rows = [ { key: "a", value: "1" } ]
      component.save!

      component.labels = { "b" => "2" }
      component.save!

      expect(component.reload.labels).to eq({ "b" => "2" })
    end

    it "keeps the last value when a key is repeated" do
      component.label_rows = [ { key: "tier", value: "gold" },
                               { key: "tier", value: "silver" } ]
      component.validate

      expect(component.labels).to eq({ "tier" => "silver" })
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
