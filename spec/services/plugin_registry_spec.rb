# frozen_string_literal: true

require "rails_helper"

RSpec.describe PluginRegistry do
  subject(:registry) { described_class.instance }

  let(:actions) { {} }
  let(:annotations) { {} }
  let(:auth_providers) { {} }
  let(:components) { [] }
  let(:sidebar_links) { [] }
  let(:tabs) { [] }
  let(:plugin) do
    instance_double(Plugin, name: "test_plugin", actions:,
                    annotations_for: annotations, auth_providers:,
                    components_for: components, sidebar_links:, tabs_for: tabs)
  end

  before { registry.reset! }

  describe "#initialize" do
    it "initializes with an empty plugins hash" do
      expect(registry.plugins).to be_empty
    end
  end

  describe "#register_plugin" do
    it "registers a new plugin" do
      registry.register_plugin(plugin)

      expect(registry.plugins).to include("test_plugin" => plugin)
    end
  end

  describe "#actions" do
    context "with no registered actions" do
      it "returns an empty hash when no plugins are registered" do
        expect(registry.actions).to eq({})
      end

      it "return an empty hash" do
        registry.register_plugin(plugin)

        expect(registry.actions).to eq({})
      end
    end

    context "with registered actions" do
      let(:actions) { { "Domain" => [ { method: :domain_path } ] } }

      it "aggregates actions from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.actions).to eq({ Domain => [ { method: :domain_path } ] })
      end
    end
  end

  describe "#annotations_for" do
    context "with no registered annotations" do
      it "returns an empty hash when no plugins are registered" do
        expect(registry.annotations_for("Domain")).to eq({})
      end

      it "return an empty hash" do
        registry.register_plugin(plugin)

        expect(registry.annotations_for("Domain")).to eq({})
      end
    end

    context "with registered annotations" do
      let(:annotations) { { "example.com/owner" => { title: "Owner" } } }

      it "returns annotations when given a class" do
        registry.register_plugin(plugin)

        expect(registry.annotations_for(Domain)).to eq({ "example.com/owner" => { title: "Owner" } })
      end

      it "returns annotations when given a model" do
        registry.register_plugin(plugin)

        expect(registry.annotations_for(create(:domain))).to eq({ "example.com/owner" => { title: "Owner" } })
      end

      it "returns annotations when given a string" do
        registry.register_plugin(plugin)

        expect(registry.annotations_for("Domain")).to eq({ "example.com/owner" => { title: "Owner" } })
      end
    end
  end

  describe "#auth_providers" do
    context "with no registered auth providers" do
      it "returns an empty hash when no plugins are registered" do
        expect(registry.auth_providers).to eq({})
      end

      it "return an empty hash" do
        registry.register_plugin(plugin)

        expect(registry.auth_providers).to eq({})
      end
    end

    context "with registered auth providers" do
      let(:auth_providers) { { "test_provider" => { provider: "test_provider" } } }


      it "aggregates auth providers from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.auth_providers).to eq({ "test_provider" => { provider: "test_provider" } })
      end
    end
  end

  describe "#components_for" do
    context "with no registered components" do
      it "returns an empty array when no plugins are registered" do
        expect(registry.components_for(context: "Domain", slot: :header)).to eq([])
      end

      it "return an empty array" do
        registry.register_plugin(plugin)

        expect(registry.components_for(context: "Domain", slot: :header)).to eq([])
      end
    end

    context "with registered components" do
      let(:components) do
        [ { component: "HeaderComponent" } ]
      end

      it "returns components when given a class" do
        registry.register_plugin(plugin)

        expect(registry.components_for(context: Domain, slot: :header)).to eq([ { component: "HeaderComponent" } ])
      end

      it "returns components when given a model" do
        registry.register_plugin(plugin)

        expect(registry.components_for(context: create(:domain), slot: :header)).to eq([ { component: "HeaderComponent" } ])
      end

      it "returns components when given a string" do
        registry.register_plugin(plugin)

        expect(registry.components_for(context: "Domain", slot: :header)).to eq([ { component: "HeaderComponent" } ])
      end
    end
  end

  describe "#plugin" do
    it "raises an error if the plugin is not found" do
      expect { registry.plugin("non_existent_plugin") }.to raise_error(PluginRegistry::PluginNotFoundError)
    end

    it "returns the plugin if found" do
      registry.register_plugin(plugin)

      expect(registry.plugin("test_plugin")).to eq(plugin)
    end
  end

  describe "#sidebar_links" do
    context "with no registered sidebar links" do
      it "returns an empty array when no plugins are registered" do
        expect(registry.sidebar_links).to eq([])
      end

      it "return an empty array" do
        registry.register_plugin(plugin)

        expect(registry.sidebar_links).to eq([])
      end
    end

    context "with registered sidebar links" do
      let(:sidebar_links) { [ { action: "/path", title: "Test Link" } ] }

      it "aggregates sidebar links from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.sidebar_links).to eq([ { action: "/path", title: "Test Link" } ])
      end
    end
  end

  describe "#tabs_for" do
    context "with no registered tabs" do
      it "returns an empty array when no plugins are registered" do
        expect(registry.tabs_for("Domain")).to eq([])
      end

      it "return an empty array" do
        registry.register_plugin(plugin)

        expect(registry.tabs_for("Domain")).to eq([])
      end
    end

    context "with registered tabs" do
      let(:tabs) { [ { title: "Details", action: :domain_path } ] }

      it "returns tabs when given a class" do
        registry.register_plugin(plugin)

        expect(registry.tabs_for(Domain)).to eq([ { title: "Details", action: :domain_path } ])
      end

      it "returns tabs when given a model" do
        registry.register_plugin(plugin)

        expect(registry.tabs_for(create(:domain))).to eq([ { title: "Details", action: :domain_path } ])
      end

      it "returns tabs when given a string" do
        registry.register_plugin(plugin)

        expect(registry.tabs_for("Domain")).to eq([ { title: "Details", action: :domain_path } ])
      end
    end
  end
end
