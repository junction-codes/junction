# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Linkable do
  subject(:component) { build(:component) }

  let(:link) { { "url" => "https://example.com/runbook", "title" => "Runbook" } }

  describe "assignment" do
    it "defaults to no links" do
      expect(component.links).to eq([])
    end

    it "keeps a well formed link" do
      component.links = [ link ]
      expect(component.links).to eq([ link ])
    end

    it "accepts symbol keys" do
      component.links = [ { url: "https://example.com", title: "Site" } ]
      expect(component.links).to eq([ { "url" => "https://example.com", "title" => "Site" } ])
    end

    it "accepts the indexed hash a form submits" do
      component.links = { "0" => link }
      expect(component.links).to eq([ link ])
    end

    it "treats nil as no links" do
      component.links = nil
      expect(component.links).to eq([])
    end

    it "discards keys it does not recognise" do
      component.links = [ link.merge("colour" => "red") ]
      expect(component.links.first).not_to have_key("colour")
    end

    it "keeps the icon when one is given" do
      component.links = [ link.merge("icon" => "book") ]
      expect(component.links.first["icon"]).to eq("book")
    end

    it "drops keys left blank rather than storing empty strings" do
      component.links = [ link.merge("icon" => "  ") ]
      expect(component.links.first).not_to have_key("icon")
    end

    it "strips surrounding whitespace" do
      component.links = [ { "url" => "  https://example.com  " } ]
      expect(component.links.first["url"]).to eq("https://example.com")
    end

    it "discards a row that is entirely blank" do
      component.links = [ link, { "url" => "", "title" => "" } ]
      expect(component.links.size).to eq(1)
    end
  end

  describe "validation" do
    it "is valid with no links" do
      expect(component).to be_valid
    end

    it "is valid when every link has a url" do
      component.links = [ link ]
      expect(component).to be_valid
    end

    it "is invalid when a link has only a title" do
      component.links = [ { "title" => "Nowhere" } ]
      expect(component).not_to be_valid
    end

    it "reports the problem on links" do
      component.links = [ { "title" => "Nowhere" } ]
      component.valid?
      expect(component.errors[:links]).to be_present
    end
  end

  describe "persistence" do
    it "round-trips through the database" do
      component.links = [ link ]
      component.save!

      expect(component.reload.links).to eq([ link ])
    end
  end
end
