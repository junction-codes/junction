# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::PluginsController", type: :request do
  context "when the user is not authenticated" do
    describe "GET /plugins" do
      it_behaves_like "an action that requires authentication", :get, -> { plugins_path }
    end
  end

  context "when the user is authenticated" do
    describe "GET /plugins" do
      before do
        sign_in_user_with_permissions(%w[junction.codes/plugins.all.read])
      end

      it_behaves_like "an action that requires permission",
        :get, -> { plugins_path }, %w[junction.codes/plugins.all.read]

      it "renders a successful response" do
        get plugins_path
        expect(response).to be_successful
      end

      it "renders the Junction Core section" do
        get plugins_path
        expect(response.body).to include("Junction Core")
      end

      it "renders the empty message when no extra plugins exist" do
        get plugins_path
        expect(response.body).to include("No plugins are currently installed beyond the built-in one")
      end

      context "when a plugin is installed beyond the built-in one" do
        let(:plugin) do
          Class.new(Junction::ApplicationPlugin) do
            plugin_name "github"
            title "GitHub"
            description "GitHub integration"
            icon "plug"
            sidebar_link action: :pull_requests_path, title: "Pull requests"
          end
        end

        before do
          stub_const("GitHubPlugin", plugin)
          allow(Junction::PluginRegistry).to receive(:plugins)
            .and_return({ "junction" => Junction::CorePlugin, "github" => plugin })

          get plugins_path
        end

        it "lists it" do
          expect(response.body).to include("GitHub")
        end

        it "says where it is declared" do
          expect(response.body).to include("GitHubPlugin")
        end

        it "names where each sidebar link goes" do
          expect(response.body).to include("pull_requests_path")
        end

        it "leaves out the domain it does not have" do
          pane = response.parsed_body
                         .at_css("[data-ruby-ui--tabs-target='content'][data-value='github']")

          expect(pane.text).not_to include("domain:")
        end
      end

      it "renders breadcrumb trail entries" do
        get plugins_path
        expect(response.body).to include("Home")
      end

      it "renders plugins breadcrumb label" do
        get plugins_path
        expect(response.body).to include("Plugins")
      end
    end
  end
end
