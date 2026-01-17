# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Plugin do
  subject(:plugin) { described_class.new(plugin_name, namespace, icon:, title:) }

  let(:plugin_name) { "test_plugin" }
  let(:namespace) { Module.new }
  let(:icon) { "test-icon" }
  let(:title) { "Custom Plugin" }

  describe "#initialize" do
    it "uses the default title when not provided" do
      plugin = described_class.new(plugin_name, namespace, icon:)

      expect(plugin.title).to eq("Test Plugin")
    end

    it "uses provided title when given" do
      expect(plugin.title).to eq(title)
    end
  end

  describe "#register" do
    before { allow(Junction::PluginRegistry).to receive(:register_plugin) }

    it "registers the plugin with Junction::PluginRegistry" do
      plugin.register
      expect(Junction::PluginRegistry).to have_received(:register_plugin).with(plugin)
    end
  end

  describe "#auth_provider" do
    let(:callback) { proc { |auth| "user" } }

    it "registers an auth provider with default values" do
      plugin.auth_provider(callback: callback)

      expect(plugin.auth_providers[:test_plugin]).to eq({
        provider: :test_plugin,
        callback: callback,
        args: [],
        icon: icon,
        title: title,
        options: {}
      })
    end

    it "registers an auth provider with custom values" do
      plugin.auth_provider("arg1", "arg2", provider: :custom_provider,  callback: callback, icon: "custom-icon", title: "Custom Title", custom_option: "value")

      expect(plugin.auth_providers[:custom_provider]).to eq({
        provider: :custom_provider,
        callback: callback,
        args: [ "arg1", "arg2" ],
        icon: "custom-icon",
        title: "Custom Title",
        options: { custom_option: "value" }
      })
    end
  end

  describe "#sidebar_link" do
    it "registers a sidebar link with default values" do
      plugin.sidebar_link(action: "/path")

      expect(plugin.sidebar_links).to contain_exactly({
        action: "/path",
        title: title,
        icon: icon,
        disabled: false
      })
    end

    it "registers a sidebar link with custom values" do
      plugin.sidebar_link(action: "/path", title: "Custom Title", icon: "custom-icon", disabled: true)

      expect(plugin.sidebar_links).to contain_exactly({
        action: "/path",
        title: "Custom Title",
        icon: "custom-icon",
        disabled: true
      })
    end

    it "registers multiple sidebar links" do
      plugin.sidebar_link(action: "/path1")
      plugin.sidebar_link(action: "/path2")

      expect(plugin.sidebar_links.size).to eq(2)
    end
  end

  describe "#for_entity" do
    let(:entity_scope) { instance_double(Junction::EntityScope) }

    before { allow(Junction::EntityScope).to receive(:new).and_return(entity_scope) }

    it "creates an EntityScope for the given context" do
      plugin.for_entity("Domain") { |scope| }

      expect(Junction::EntityScope).to have_received(:new).with(plugin, "Domain", nil)
    end

    it "creates an EntityScope with a condition" do
      condition = proc { true }
      plugin.for_entity("Domain", condition) { |scope| }

      expect(Junction::EntityScope).to have_received(:new).with(plugin, "Domain", condition)
    end

    it "yields the EntityScope to the block" do
      expect { |block| plugin.for_entity("Domain", &block) }.to yield_with_args(entity_scope)
    end
  end

  describe "#actions" do
    let(:entity_scope) { instance_double(Junction::EntityScope, actions: [ { path: "/path" } ]) }

    before { allow(Junction::EntityScope).to receive(:new).and_return(entity_scope) }

    it "returns empty hash when no entities are registered" do
      expect(plugin.actions).to eq({})
    end

    it "returns actions grouped by context" do
      plugin.for_entity("Domain") { |scope| }
      expect(plugin.actions).to eq({ "Domain" => [ { path: "/path" } ] })
    end
  end

  describe "#annotations_for" do
    let(:entity_scope) { instance_double(Junction::EntityScope, annotations: [ { key: "example.com/annotation" } ]) }

    before { allow(Junction::EntityScope).to receive(:new).and_return(entity_scope) }

    it "returns empty hash when context is not registered" do
      expect(plugin.annotations_for("Domain")).to eq({})
    end

    it "returns annotations for registered context" do
      plugin.for_entity("Domain") { |scope| }

      expect(plugin.annotations_for("Domain")).to eq([ { key: "example.com/annotation" } ])
    end
  end

  describe "#components_for" do
    let(:entity_scope) { instance_double(Junction::EntityScope, components_for: [ { component: "MyComponent" } ]) }

    before { allow(Junction::EntityScope).to receive(:new).and_return(entity_scope) }

    it "returns empty array when context is not registered" do
      expect(plugin.components_for("Junction::Domain", :header)).to eq([])
    end

    it "returns components for registered context and slot" do
      plugin.for_entity("Junction::Domain") { |scope| }

      expect(plugin.components_for("Junction::Domain", :header)).to eq([ { component: "MyComponent" } ])
    end
  end

  describe "#tabs_for" do
    let(:entity_scope) { instance_double(Junction::EntityScope, tabs: [ { name: "tab1" } ]) }

    before { allow(Junction::EntityScope).to receive(:new).and_return(entity_scope) }

    it "returns empty array when context is not registered" do
      expect(plugin.tabs_for("Junction::Project")).to eq([])
    end

    it "returns tabs for registered context" do
      plugin.for_entity("Junction::Project") { |scope| }

      expect(plugin.tabs_for("Junction::Project")).to eq([ { name: "tab1" } ])
    end
  end

  describe "#resolve" do
    let(:test_class) { Class.new }
    let(:namespace) do
      Module.new.tap do |mod|
        mod.const_set("TestClass", test_class)
      end
    end

    it "resolves a constant within the plugin's namespace" do
      expect(plugin.resolve("TestClass")).to eq(test_class)
    end

    it "raises NameError when constant does not exist" do
      expect { plugin.resolve("NonExistent") }.to raise_error(NameError)
    end
  end
end
