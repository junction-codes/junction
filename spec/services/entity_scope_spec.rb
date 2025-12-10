# frozen_string_literal: true

require "rails_helper"

RSpec.describe EntityScope do
  subject(:entity_scope) { described_class.new(plugin, context, condition) }

  let(:plugin) { instance_double(Plugin) }
  let(:context) { "Domain" }
  let(:condition) { nil }

  describe "#action" do
    it "registers an action with required parameters" do
      entity_scope.action(method: :domain_path, controller: "domains", action: :show)

      expect(entity_scope.actions).to contain_exactly({
        method: :domain_path,
        controller: "domains",
        action: :show,
        path: nil
      })
    end

    it "registers an action with a custom path" do
      entity_scope.action(method: :domain_path, controller: "domains", action: :show, path: "/custom/path")

      expect(entity_scope.actions.first[:path]).to eq("/custom/path")
    end

    it "defaults action to :index when not provided" do
      entity_scope.action(method: :domains_path, controller: "domains")

      expect(entity_scope.actions.first[:action]).to eq(:index)
    end

    it "registers multiple actions" do
      entity_scope.action(method: :domain_path, controller: "domains", action: :show)
      entity_scope.action(method: :domains_path, controller: "domains", action: :index)

      expect(entity_scope.actions.size).to eq(2)
    end
  end

  describe "#annotation" do
    it "registers an annotation with required parameters" do
      entity_scope.annotation(key: "example.com/owner", title: "Owner")

      expect(entity_scope.annotations["example.com/owner"]).to eq({
        key: "example.com/owner",
        title: "Owner",
        placeholder: nil
      })
    end

    it "registers an annotation with custom values" do
      entity_scope.annotation(key: "example.com/owner", title: "Owner", placeholder: "Me")

      expect(entity_scope.annotations["example.com/owner"]).to eq({
        key: "example.com/owner",
        title: "Owner",
        placeholder: "Me"
      })
    end

    it "registers multiple annotations with different keys" do
      entity_scope.annotation(key: "example.com/owner", title: "Owner")
      entity_scope.annotation(key: "example.com/team", title: "Team")

      expect(entity_scope.annotations.size).to eq(2)
    end
  end

  describe "#component" do
    it "registers a component for a slot" do
      entity_scope.component(slot: :header, component: "HeaderComponent")

      expect(entity_scope.send(:instance_variable_get, :@components)[:header]).to contain_exactly({
        slot: :header,
        component: "HeaderComponent",
        if: nil
        })
    end

    it "registers multiple components for the same slot" do
      entity_scope.component(slot: :header, component: "ComponentA")
      entity_scope.component(slot: :header, component: "ComponentB")

      components = entity_scope.send(:instance_variable_get, :@components)[:header]
      expect(components.size).to eq(2)
    end

    it "registers components for different slots" do
      entity_scope.component(slot: :header, component: "HeaderComponent")
      entity_scope.component(slot: :footer, component: "FooterComponent")

      component_map = entity_scope.send(:instance_variable_get, :@components)
      expect(component_map[:header].size).to eq(1)
    end

    context "A condition is provided" do
      let(:condition) { proc { true } }

      it "registers a component with a condition" do
        entity_scope.component(slot: :header, component: "HeaderComponent")

        components = entity_scope.send(:instance_variable_get, :@components)[:header]
        expect(components.first[:if]).to eq(condition)
      end
    end
  end

  describe "#tab" do
    it "registers a tab with required parameters" do
      entity_scope.tab(title: "Details", action: :domain_path)

      expect(entity_scope.tabs).to contain_exactly({
        title: "Details",
        action: :domain_path,
        icon: nil,
        if: nil,
        target: "domain"
      })
    end

    it "registers a tab with custom values" do
      entity_scope.tab(title: "Details", action: :domain_path, icon: "info-icon", target: "details-frame")

      expect(entity_scope.tabs).to contain_exactly({
        title: "Details",
        action: :domain_path,
        icon: "info-icon",
        if: nil,
        target: "details-frame"
      })
    end

    it "generates target from title when action is nil" do
      entity_scope.tab(title: "Custom Tab", action: nil)

      expect(entity_scope.tabs.first[:target]).to eq("custom-tab")
    end

    it "registers multiple tabs" do
      entity_scope.tab(title: "Details", action: :domain_path)
      entity_scope.tab(title: "Settings", action: :domain_settings_path)

      expect(entity_scope.tabs.size).to eq(2)
    end

    context "A condition is provided" do
      let(:condition) { proc { true } }

      it "registers a tab with a condition" do
        entity_scope.tab(title: "Details", action: :domain_path)

        expect(entity_scope.tabs.first[:if]).to eq(condition)
      end
    end
  end

  describe "#components_for" do
    before do
      allow(plugin).to receive(:resolve) do |component_name|
        component_name
      end
    end

    it "returns empty array when slot is not registered" do
      expect(entity_scope.components_for(:header)).to eq([])
    end

    it "returns components for a registered slot" do
      entity_scope.component(slot: :header, component: "HeaderComponent")

      expect(entity_scope.components_for(:header)).to contain_exactly({
        slot: :header,
        component: "HeaderComponent",
        if: nil
      })
    end

    it "returns multiple components for a slot" do
      entity_scope.component(slot: :header, component: "ComponentA")
      entity_scope.component(slot: :header, component: "ComponentB")

      components = entity_scope.components_for(:header)

      expect(components.size).to eq(2)
    end

    it "returns only components for the requested slot" do
      entity_scope.component(slot: :header, component: "HeaderComponent")
      entity_scope.component(slot: :footer, component: "FooterComponent")

      expect(entity_scope.components_for(:header)).to contain_exactly({
        slot: :header,
        component: "HeaderComponent",
        if: nil
      })
    end
  end
end
