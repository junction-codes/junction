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

  describe "url scheme" do
    it "accepts an https url" do
      component.links = [ { url: "https://runbook.example.com" } ]
      expect(component).to be_valid
    end

    it "accepts an http url" do
      component.links = [ { url: "http://runbook.example.com" } ]
      expect(component).to be_valid
    end

    it "rejects a url with no scheme, which would resolve inside Junction" do
      component.links = [ { url: "runbook.example.com" } ]
      expect(component).not_to be_valid
    end

    it "rejects a scheme other than http or https" do
      component.links = [ { url: "javascript:alert(1)" } ]
      expect(component).not_to be_valid
    end

    it "rejects a relative path that merely contains a url" do
      component.links = [ { url: "/dashboards/1?next=https://x.example.com" } ]
      expect(component).not_to be_valid
    end

    it "rejects a javascript url that mentions a http one" do
      component.links = [ { url: "javascript:alert('http://x.example.com')" } ]
      expect(component).not_to be_valid
    end

    it "accepts a url with a path and query of its own" do
      component.links = [ { url: "https://x.example.com/d/1?tab=logs" } ]
      expect(component).to be_valid
    end

    it "reports the problem on links" do
      component.links = [ { url: "runbook.example.com" } ]
      component.validate

      expect(component.errors[:links]).to be_present
    end
  end

  describe "icon names" do
    it "accepts a plain slug" do
      component.links = [ { url: "https://x.example.com", icon: "book-open" } ]
      expect(component).to be_valid
    end

    it "rejects one that could traverse out of the icon directory" do
      component.links = [ { url: "https://x.example.com", icon: "../../etc/passwd" } ]
      expect(component).not_to be_valid
    end

    it "rejects a path separator" do
      component.links = [ { url: "https://x.example.com", icon: "outline/circle" } ]
      expect(component).not_to be_valid
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
