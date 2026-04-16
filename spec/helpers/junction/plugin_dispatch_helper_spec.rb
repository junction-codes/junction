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
    let(:url_helpers) { Junction::Engine.routes.url_helpers }
    let(:fake_plugin_path) { :junction_plugin_dispatch_spec_fake_path }

    before do
      allow(Junction::PluginRegistry).to receive(:plugin_route_helper_entity_classes)
        .and_return({ fake_plugin_path => Junction::Component })

      allow(url_helpers).to receive(:respond_to?).and_wrap_original do |method, sym, *rest|
        sym == fake_plugin_path || method.call(sym, *rest)
      end

      allow(url_helpers).to receive(fake_plugin_path) do |**kwargs|
        "/components/#{kwargs.fetch(:namespace)}/#{kwargs.fetch(:name)}/spec-fake-plugin"
      end
    end

    it "expands a sluggable catalog record into namespace/name for plugin routes" do
      component = create(:component, title: "Junction", namespace: "default", name: "junction")

      path = host.send(:resolve_plugin_route, fake_plugin_path, component)

      expect(path).to eq("/components/default/junction/spec-fake-plugin")
    end

    it "raises when the helper does not exist" do
      expect do
        host.send(:resolve_plugin_route, :totally_unknown_junction_plugin_path)
      end.to raise_error(ArgumentError, /Unknown plugin route helper/)
    end
  end
end
