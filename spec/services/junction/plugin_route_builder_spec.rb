# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::PluginRouteBuilder do
  describe ".draw" do
    let(:router) { instance_double(ActionDispatch::Routing::Mapper) }
    let(:context_class) { stub_const("Junction::Integrations::Api", Class.new) }
    let(:actions) do
      {
        context_class => [
          { method: :integration_api_path, controller: "junction/apis", action: :index, path: "custom/path" },
          { method: :api_github_actions_path, controller: "junction/apis", action: :index, path: "github/actions" }
        ]
      }
    end

    before do
      allow(Junction::PluginRegistry).to receive(:actions).and_return(actions)
      allow(router).to receive(:get)
      allow(router).to receive(:resources).with(:apis).and_yield
    end

    it "uses demodulized context for resource names" do
      described_class.draw(router)

      expect(router).to have_received(:get)
        .with("custom/path", to: "/junction/apis#index", as: :integration_api)
    end

    it "avoids double-prefixed helper names" do
      described_class.draw(router)

      expect(router).to have_received(:get)
       .with("github/actions", to: "/junction/apis#index", as: :github_actions)
    end
  end
end
