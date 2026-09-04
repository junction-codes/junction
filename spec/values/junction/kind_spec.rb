# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Kind do
  subject(:kind) do
    described_class.new(:api, catalog: true, ownable: true, dependable: true,
                        default_icon: "webhook")
  end

  describe "#name" do
    it "camelizes the scope into the STI discriminator value" do
      expect(kind.name).to eq("Api")
    end

    it "camelizes a multi-word scope" do
      expect(described_class.new(:ai_resource).name).to eq("AiResource")
    end
  end

  describe "#plural" do
    it "pluralizes the scope" do
      expect(kind.plural).to eq("apis")
    end
  end

  describe "#context" do
    it "matches the plural form" do
      expect(kind.context).to eq("apis")
    end
  end

  describe "#section" do
    it "is the plural form as a symbol" do
      expect(kind.section).to eq(:apis)
    end
  end

  describe "#model_name" do
    it "defaults to the kind's name in the Junction namespace" do
      expect(kind.model_name).to eq("Junction::Api")
    end

    it "uses an explicit model name when given" do
      plugin_kind = described_class.new(:widget, model_name: "MyPlugin::Widget")
      expect(plugin_kind.model_name).to eq("MyPlugin::Widget")
    end
  end

  describe "#model" do
    it "resolves the model constant" do
      expect(kind.model).to eq(Junction::Api)
    end
  end

  describe "flags" do
    it "reports catalog membership" do
      expect(kind).to be_catalog
    end

    it "reports ownability" do
      expect(kind).to be_ownable
    end

    it "reports dependability" do
      expect(kind).to be_dependable
    end

    it "defaults sluggable to true" do
      expect(kind).to be_sluggable
    end

    it "defaults tree to false" do
      expect(kind).not_to be_tree
    end

    it "defaults catalog to false" do
      expect(described_class.new(:user)).not_to be_catalog
    end
  end

  describe "#default_icon" do
    it "returns the configured icon" do
      expect(kind.default_icon).to eq("webhook")
    end

    it "falls back to a generic icon" do
      expect(described_class.new(:user).default_icon).to eq("circle")
    end
  end
end
