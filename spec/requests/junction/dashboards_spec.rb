# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/dashboard", type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  context "when the user is not authenticated" do
    describe "GET /dashboard" do
      it_behaves_like "an action that requires authentication", :get, -> { dashboard_path }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /dashboard" do
      it_behaves_like "an action that requires permission",
        :get, -> { dashboard_path }, %w[junction.codes/dashboards.all.read]

      it "returns a success response" do
        get dashboard_path
        expect(response).to have_http_status(:success)
      end

      it "renders the dashboard view" do
        get dashboard_path
        expect(response.body).to include("Welcome")
      end

      context "with owned entities" do
        before do
          create(:group_membership, user: junction_users(:one), group: group)
          [ :api, :component, :domain, :resource, :system ].each do |factory|
            create(factory, owner: group)
          end
        end

        it "includes owned entities in the response" do
          get dashboard_path
          expect(response.body).to include("My catalog items")
        end

        %w[API Component Domain Resource System].each do |entity_type|
          it "displays owned #{entity_type} entity" do
            get dashboard_path
            expect(response.body).to include(entity_type)
          end
        end
      end

      context "with recently updated entities" do
        before do
          %i[api component domain resource system].each_with_index do |factory, i|
            create(factory, updated_at: (i + 1).hours.ago)
          end
        end

        it "includes recent catalog updates section" do
          get dashboard_path
          expect(response.body).to include("Recent catalog updates")
        end
      end

      context "with no owned entities" do
        it "shows empty state for my entities" do
          get dashboard_path
          expect(response.body).to include("No entities owned by your groups yet.")
        end
      end

      context "with no recent catalog items" do
        before do
          [ Junction::Deployment, Junction::Api, Junction::Component,
            Junction::Domain, Junction::Resource, Junction::System ].each(&:delete_all)
        end

        it "shows empty state for recent updates" do
          get dashboard_path
          expect(response.body).to include("No catalog updates yet.")
        end
      end

      context "with group hierarchy" do
        let(:parent_group) { create(:group) }
        let(:child_group) { create(:group, parent: parent_group) }

        before do
          create(:group_membership, user: junction_users(:one), group: child_group)
          create(:api, owner: parent_group)
        end

        it "includes entities from parent groups" do
          get dashboard_path
          expect(response.body).to include("API")
        end
      end
    end
  end
end
