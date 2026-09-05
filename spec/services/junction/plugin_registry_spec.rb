# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::PluginRegistry do
  subject(:registry) { described_class.instance }

  let(:methods) do
    { actions: {}, annotations_for: {}, auth_providers: {}, components_for: [],
      permissions: [], settings_menu_items: [], sidebar_links: [],
      tabs_for: [] }
  end

  let(:plugin) do
    class_double(Junction::ApplicationPlugin, plugin_name: "test_plugin", **methods)
  end

  before { registry.reset! }

  # Make sure later specs see a clean registry by resetting the process-wide
  # singleton.
  after do
    registry.reset!
    Junction::CorePlugin.register
  end

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

    context "with plugin route helpers" do
      let(:methods) { super().merge(actions:) }
      let(:actions) do
        {
          "Junction::Component" => [ {
            method: :component_github_actions_path,
            controller: "x",
            action: "y",
            path: "github/actions"
          } ],
          "Junction::Api" => [ {
            method: :api_github_actions_path,
            controller: "x",
            action: "y",
            path: "github/actions"
          } ]
        }
      end

      it "maps plugin route helpers to their entity classes" do
        registry.register_plugin(plugin)

        expect(registry.plugin_route_helper_entity_classes).to eq(
          component_github_actions_path: Junction::Component,
          api_github_actions_path: Junction::Api
        )
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

      before do
        allow(plugin).to receive(:annotations_for)
          .with("Junction::Domain").and_return(annotations)
      end

      it_behaves_like "context type handling", "annotations",
                      { "example.com/owner" => { title: "Owner" } },
                      ->(registry, context) { registry.annotations_for(context) }
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

      before do
        allow(plugin).to receive(:components_for)
          .with("Junction::Domain", :header).and_return(components)
      end

      it_behaves_like "context type handling", "components",
                      [ { component: "HeaderComponent" } ],
                      ->(registry, context) { registry.components_for(context:, slot: :header) }
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

  describe "#settings_menu_items" do
    it_behaves_like "registry aggregation method", :settings_menu_items, [], {}

    context "with registered settings menu items" do
      let(:settings_menu_items) { [ { action: "/settings", title: "Settings Link" } ] }
      let(:methods) { super().merge(settings_menu_items:) }

      it "aggregates settings menu items from registered plugins" do
        registry.register_plugin(plugin)

        expect(registry.settings_menu_items).to eq([ { action: "/settings", title: "Settings Link" } ])
      end
    end
  end

  describe "#tabs_for" do
    it_behaves_like "registry aggregation method", :tabs_for, [], { context: "Junction::Domain" }

    context "with registered tabs" do
      let(:tabs) { [ { title: "Details", action: :domain_path } ] }

      before do
        allow(plugin).to receive(:tabs_for)
          .with("Junction::Domain").and_return(tabs)
      end

      it_behaves_like "context type handling", "tabs",
                      [ { title: "Details", action: :domain_path } ],
                      ->(registry, context) { registry.tabs_for(context) }
    end
  end

  describe "entity kind inheritance" do
    let(:tabs) { [ { title: "Details", action: :component_path } ] }
    let(:annotations) { { "example.com/owner" => { title: "Owner" } } }

    before do
      stub_const("MyPlugin::Widget", Class.new(Junction::Component))
      registry.register_plugin(plugin)
    end

    it "answers a subclass with the tabs registered for its parent kind" do
      allow(plugin).to receive(:tabs_for)
        .with("Junction::Component").and_return(tabs)

      expect(registry.tabs_for(MyPlugin::Widget)).to eq(tabs)
    end

    it "answers a subclass with the annotations registered on the base class" do
      allow(plugin).to receive(:annotations_for)
        .with("Junction::Entity").and_return(annotations)

      expect(registry.annotations_for(MyPlugin::Widget)).to eq(annotations)
    end

    it "lets the more specific registration win" do
      allow(plugin).to receive(:annotations_for)
        .with("Junction::Entity").and_return(annotations)
      allow(plugin).to receive(:annotations_for)
        .with("MyPlugin::Widget")
        .and_return({ "example.com/owner" => { title: "Widget Owner" } })

      expect(registry.annotations_for(MyPlugin::Widget))
        .to eq({ "example.com/owner" => { title: "Widget Owner" } })
    end

    it "does not leak a subclass registration to its parent kind" do
      allow(plugin).to receive(:tabs_for)
        .with("MyPlugin::Widget").and_return(tabs)

      expect(registry.tabs_for(Junction::Component)).to eq([])
    end

    it "looks a context that is not an entity up under itself alone" do
      expect(registry.send(:inherited_contexts, "Junction::Session"))
        .to eq([ "Junction::Session" ])
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
