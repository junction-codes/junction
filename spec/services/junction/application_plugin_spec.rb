# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::ApplicationPlugin do
  subject(:plugin_class) do
    Class.new(described_class) do
      plugin_name "test_plugin"
      icon "test-icon"
      title "Custom Plugin"
    end
  end

  describe ".title" do
    it "falls back to titleized plugin_name when not set" do
      klass = Class.new(described_class) { plugin_name "my_plugin" }

      expect(klass.title).to eq("My Plugin")
    end

    it "returns the configured title when set" do
      expect(plugin_class.title).to eq("Custom Plugin")
    end
  end

  describe ".register" do
    before { allow(Junction::PluginRegistry).to receive(:register_plugin) }

    it "registers the plugin class with Junction::PluginRegistry" do
      plugin_class.register

      expect(Junction::PluginRegistry).to have_received(:register_plugin)
        .with(plugin_class)
    end

    it "raises ArgumentError when plugin_name is nil" do
      klass = Class.new(described_class)

      expect { klass.register }.to raise_error(ArgumentError, /invalid/)
    end

    it "raises ArgumentError when plugin_name has invalid format" do
      klass = Class.new(described_class) { plugin_name "Invalid-Name" }

      expect { klass.register }.to raise_error(ArgumentError, /invalid/)
    end
  end

  describe ".auth_provider" do
    let(:callback) { proc { |auth| "user" } }

    it "registers an auth provider with default values" do
      plugin_class.auth_provider(callback: callback)

      expect(plugin_class.auth_providers[:test_plugin]).to eq({
        provider: :test_plugin,
        callback: callback,
        args: [],
        icon: "test-icon",
        title: "Custom Plugin",
        options: {}
      })
    end

    it "registers an auth provider with custom values" do
      plugin_class.auth_provider("arg1", "arg2", provider: :custom_provider,
                                                  callback: callback,
                                                  icon: "custom-icon",
                                                  title: "Custom Title",
                                                  custom_option: "value")

      expect(plugin_class.auth_providers[:custom_provider]).to eq({
        provider: :custom_provider,
        callback: callback,
        args: [ "arg1", "arg2" ],
        icon: "custom-icon",
        title: "Custom Title",
        options: { custom_option: "value" }
      })
    end

    it_behaves_like "plugin registration method allows multiple",
                    :auth_provider, :auth_providers,
                    { callback: proc { }, provider: :provider_a },
                    { callback: proc { }, provider: :provider_b }
  end

  describe ".sidebar_link" do
    it "registers a sidebar link with default values" do
      plugin_class.sidebar_link(action: "/path")

      expect(plugin_class.sidebar_links).to contain_exactly({
        action: "/path",
        title: "Custom Plugin",
        icon: "test-icon",
        disabled: false
      })
    end

    it "registers a sidebar link with custom values" do
      plugin_class.sidebar_link(action: :my_plugin_root_path,
                                title: "My Plugin Root", icon: "custom-icon",
                                disabled: true)

      expect(plugin_class.sidebar_links).to contain_exactly({
        action: :my_plugin_root_path,
        title: "My Plugin Root",
        icon: "custom-icon",
        disabled: true
      })
    end

    it_behaves_like "plugin registration method allows multiple",
                    :sidebar_link, :sidebar_links,
                    { action: "/path1" },
                    { action: "/path2" }
  end

  describe ".settings_menu_item" do
    it "registers a settings item with explicit title" do
      plugin_class.settings_menu_item(action: "/settings-path", title: "Settings Path")

      expect(plugin_class.settings_menu_items).to contain_exactly({
        action: "/settings-path",
        title: "Settings Path",
        title_i18n: nil,
        icon: "test-icon",
        disabled: false,
        access: nil
      })
    end

    it "registers a settings item with custom values" do
      plugin_class.settings_menu_item(
        action: :my_plugin_settings_path,
        title: "Plugin Settings",
        icon: "custom-icon",
        disabled: true
      )

      expect(plugin_class.settings_menu_items).to contain_exactly({
        action: :my_plugin_settings_path,
        title: "Plugin Settings",
        title_i18n: nil,
        icon: "custom-icon",
        disabled: true,
        access: nil
      })
    end

    it "registers a settings item with access requirements" do
      access = { action: :index?, record: :roles }
      plugin_class.settings_menu_item(action: :roles_path, title: "Roles", access:)

      expect(plugin_class.settings_menu_items.first[:access]).to eq(access)
    end

    it "registers a settings item with an i18n title key" do
      plugin_class.settings_menu_item(action: :roles_path, title_i18n: "junction.roles")

      expect(plugin_class.settings_menu_items.first[:title_i18n]).to eq("junction.roles")
    end

    it "raises when neither title nor title_i18n is provided" do
      expect {
        plugin_class.settings_menu_item(action: "/settings-path")
      }.to raise_error(ArgumentError, /require either title or title_i18n/)
    end

    it_behaves_like "plugin registration method allows multiple",
                    :settings_menu_item, :settings_menu_items,
                    { action: "/settings-one", title: "Settings One" },
                    { action: "/settings-two", title: "Settings Two" }
  end

  describe ".for_entity" do
    let(:entity_scope) { instance_double(Junction::EntityScope) }

    before do
      allow(Junction::EntityScope).to receive(:new).and_return(entity_scope)
    end

    it "creates an EntityScope for the given context" do
      plugin_class.for_entity("Domain") { |scope| }

      expect(Junction::EntityScope).to have_received(:new)
        .with(plugin_class, "Domain", nil)
    end

    it "creates an EntityScope with a condition" do
      condition = proc { true }
      plugin_class.for_entity("Domain", condition) { |scope| }

      expect(Junction::EntityScope).to have_received(:new)
        .with(plugin_class, "Domain", condition)
    end

    it "yields the EntityScope to the block" do
      expect { |block| plugin_class.for_entity("Domain", &block) }.to \
        yield_with_args(entity_scope)
    end
  end

  describe ".actions" do
    let(:entity_scope) do
      instance_double(Junction::EntityScope, actions: [ { path: "/path" } ])
    end

    before do
      allow(Junction::EntityScope).to receive(:new).and_return(entity_scope)
    end

    it "returns empty hash when no entities are registered" do
      expect(plugin_class.actions).to eq({})
    end

    it "returns actions grouped by context" do
      plugin_class.for_entity("Domain") { |scope| }

      expect(plugin_class.actions).to eq({ "Domain" => [ { path: "/path" } ] })
    end
  end

  describe ".annotations_for" do
    let(:annotations) do
      {
        "example.com/annotation" => {
          key: "example.com/annotation",
          title: "Annotation"
        }
      }
    end

    let(:entity_scope) do
      instance_double(Junction::EntityScope, annotations: annotations)
    end

    before do
      allow(Junction::EntityScope).to receive(:new).and_return(entity_scope)
    end

    it "returns empty hash when context is not registered" do
      expect(plugin_class.annotations_for("Domain")).to eq({})
    end

    it "returns annotations for registered context" do
      plugin_class.for_entity("Domain") { |scope| }

      expect(plugin_class.annotations_for("Domain")).to eq(annotations)
    end
  end

  describe ".components_for" do
    let(:entity_scope) do
      instance_double(Junction::EntityScope, components_for: [ { component: "MyComponent" } ])
    end

    before do
      allow(Junction::EntityScope).to receive(:new).and_return(entity_scope)
    end

    it "returns empty array when context is not registered" do
      expect(plugin_class.components_for("Junction::Domain", :header)).to eq([])
    end

    it "returns components for registered context and slot" do
      plugin_class.for_entity("Junction::Domain") { |scope| }

      expect(plugin_class.components_for("Junction::Domain", :header)).to \
        eq([ { component: "MyComponent" } ])
    end
  end

  describe ".tabs_for" do
    let(:entity_scope) do
      instance_double(Junction::EntityScope, tabs: [ { name: "tab1" } ])
    end

    before do
      allow(Junction::EntityScope).to receive(:new).and_return(entity_scope)
    end

    it "returns empty array when context is not registered" do
      expect(plugin_class.tabs_for("Junction::Project")).to eq([])
    end

    it "returns tabs for registered context" do
      plugin_class.for_entity("Junction::Project") { |scope| }

      expect(plugin_class.tabs_for("Junction::Project")).to \
        eq([ { name: "tab1" } ])
    end
  end

  describe ".permission" do
    it "registers a global permission using the plugin's domain" do
      plugin_class.permission(context: "domains", ownership: "all",
                              access: "read")

      expect(plugin_class.permissions).not_to be_empty
    end
  end

  describe ".permissions" do
    it "returns empty array when no permissions are registered" do
      expect(plugin_class.permissions).to eq([])
    end

    it "includes global permissions" do
      plugin_class.permission(context: "domains", ownership: "all",
                              access: "read")

      expect(plugin_class.permissions.size).to eq(1)
    end
  end

  describe ".resolve" do
    it "resolves a constant within the plugin's namespace" do
      stub_const("TestPluginNamespace::MyClass", Class.new)
      stub_const("TestPluginNamespace::Plugin",
        Class.new(described_class) { plugin_name "test_namespace" })

      expect(TestPluginNamespace::Plugin.resolve("MyClass")).to \
        eq(TestPluginNamespace::MyClass)
    end

    it "raises NameError when constant does not exist" do
      expect { Junction::CorePlugin.resolve("NonExistent") }.to \
        raise_error(NameError)
    end

    it "raises RuntimeError for anonymous plugin classes" do
      expect { plugin_class.resolve("Something") }.to \
        raise_error(RuntimeError, /anonymous/)
    end
  end
end
