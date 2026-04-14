# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::PluginDispatchHelper do
  subject(:host) { host_class.new }

  let(:host_class) do
    Class.new do
      include Junction::PluginDispatchHelper
    end
  end

  describe "#resolve_plugin_route" do
    before do
      allow(Junction::PluginRegistry).to receive(:plugin_route_helper_entity_classes)
        .and_return({ component_github_actions_path: Junction::Component })
    end

    it "expands a sluggable catalog record into namespace/name for plugin routes" do
      component = create(:component, title: "Junction", namespace: "default", name: "junction")

      path = host.send(:resolve_plugin_route, :component_github_actions_path, component)

      expect(path).to eq("/components/default/junction/component/github/actions")
    end

    it "raises when the helper does not exist" do
      expect do
        host.send(:resolve_plugin_route, :totally_unknown_junction_plugin_path)
      end.to raise_error(ArgumentError, /Unknown plugin route helper/)
    end
  end
end
