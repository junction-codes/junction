# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::PluginRegistry do
  subject(:registry) { described_class.instance }

  let(:methods) do
    { actions: {}, annotations_for: {}, auth_providers: {}, components_for: [],
      permissions: [], sidebar_links: [], tabs_for: [] }
  end

  let(:plugin) do
    class_double(Junction::ApplicationPlugin, plugin_name: "test_plugin", **methods)
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
    it_behaves_like "registry aggregation method", :actions, {}, {}

    context "with registered actions" do
      let(:actions) { { "Junction::Domain" => [ { method: :domain_path } ] } }
      let(:methods) { super().merge(actions:) }

      it "aggregates actions from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.actions).to eq({ Junction::Domain => [ { method: :domain_path } ] })
      end
    end

    context "with an unknown context class" do
      let(:actions) { { "Unknown::Ghost" => [ { method: :ghost_path } ] } }
      let(:methods) { super().merge(actions:) }

      it "skips the unknown context" do
        registry.register_plugin(plugin)

        expect(registry.actions).not_to have_key("Unknown::Ghost")
      end

      it "logs an error for the unknown context" do
        allow(Rails.logger).to receive(:error)
        registry.register_plugin(plugin)
        registry.actions

        expect(Rails.logger).to have_received(:error)
          .with(/test_plugin.*Unknown::Ghost/i)
      end
    end
  end

  describe "#annotations_for" do
    it_behaves_like "registry aggregation method", :annotations_for, {}, { context: "Junction::Domain" }

    context "with registered annotations" do
      let(:annotations) { { "example.com/owner" => { title: "Owner" } } }
      let(:methods) { super().merge(annotations_for: annotations) }

      it_behaves_like "context type handling", :annotations_for, { "example.com/owner" => { title: "Owner" } }, {}
    end
  end

  describe "#auth_providers" do
    it_behaves_like "registry aggregation method", :auth_providers, {}, {}

    context "with registered auth providers" do
      let(:auth_providers) { { "test_provider" => { provider: "test_provider" } } }
      let(:methods) { super().merge(auth_providers:) }

      it "aggregates auth providers from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.auth_providers).to eq(auth_providers)
      end
    end
  end

  describe "#components_for" do
    it_behaves_like "registry aggregation method", :components_for, [], { context: "Junction::Domain", slot: :header }

    context "with registered components" do
      let(:components) { [ { component: "HeaderComponent" } ] }
      let(:methods) { super().merge(components_for: components) }

      it_behaves_like "context type handling", :components_for, [ { component: "HeaderComponent" } ], { slot: :header }
    end
  end

  describe "#plugin" do
    it "raises an error if the plugin is not found" do
      expect { registry.plugin("non_existent_plugin") }.to raise_error(Junction::PluginRegistry::PluginNotFoundError)
    end

    it "returns the plugin if found" do
      registry.register_plugin(plugin)

      expect(registry.plugin("test_plugin")).to eq(plugin)
    end
  end

  describe "#sidebar_links" do
    it_behaves_like "registry aggregation method", :sidebar_links, [], {}

    context "with registered sidebar links" do
      let(:sidebar_links) { [ { action: "/path", title: "Test Link" } ] }
      let(:methods) { super().merge(sidebar_links:) }

      it "aggregates sidebar links from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.sidebar_links).to eq([ { action: "/path", title: "Test Link" } ])
      end
    end
  end

  describe "#tabs_for" do
    it_behaves_like "registry aggregation method", :tabs_for, [], { context: "Junction::Domain" }

    context "with registered tabs" do
      let(:tabs) { [ { title: "Details", action: :domain_path } ] }
      let(:methods) { super().merge(tabs_for: tabs) }

      it_behaves_like "context type handling", :tabs_for, [ { title: "Details", action: :domain_path } ], {}
    end
  end

  describe "#resolve" do
    it "delegates to the plugin's resolve method" do
      klass = Class.new
      allow(plugin).to receive(:resolve).with("MyClass").and_return(klass)
      registry.register_plugin(plugin)

      expect(registry.resolve("test_plugin", "MyClass")).to eq(klass)
    end

    it "raises PluginNotFoundError for unknown plugin name" do
      expect { registry.resolve("unknown", "MyClass") }.to \
        raise_error(Junction::PluginRegistry::PluginNotFoundError)
    end
  end
end
