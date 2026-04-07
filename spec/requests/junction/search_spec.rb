# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/search", type: :request do
  context "when the user is not authenticated" do
    describe "GET /search" do
      it_behaves_like "an action that requires authentication", :get, -> { search_path }
    end

    describe "GET /search/autocomplete" do
      it_behaves_like "an action that requires authentication", :get, -> { search_autocomplete_path }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /search" do
      context "with no query" do
        before { sign_in_user_with_permissions(%w[junction.codes/apis.all.read]) }

        it "returns http success" do
          get search_path
          expect(response).to be_successful
        end
      end

      context "with a query matching an entity the user can read" do
        let!(:api) { create(:api) }

        before { sign_in_user_with_permissions(%w[junction.codes/apis.all.read]) }

        it "includes the matching entity" do
          get search_path, params: { q: api.title }
          expect(response.body).to include(api.title)
        end
      end

      context "when the user only has owned.read for a model" do
        let(:user) { create_user_with_permissions(%w[junction.codes/apis.owned.read]) }
        let!(:owned_api) { create(:api, owner: user.groups.first) }
        let!(:other_api) { create(:api) }

        before { sign_in(user:, password: user.password) }

        it "includes apis owned by the user's group" do
          get search_path, params: { q: owned_api.title }
          expect(response.body).to include(owned_api.title)
        end

        it "excludes apis not owned by the user's group" do
          get search_path, params: { q: other_api.title }
          expect(response.body).not_to include(api_path(other_api))
        end
      end

      context "when sorting by kind" do
        let!(:api) { create(:api, title: "Sort Test API") }
        let!(:component) { create(:component, title: "Sort Test Component") }

        before do
          sign_in_user_with_permissions([
            "junction.codes/apis.all.read",
            "junction.codes/components.all.read"
          ])
        end

        it "returns results sorted by kind ascending" do
          get search_path, params: { q: "Sort Test", s: "kind asc" }

          expect(response.body.index(api_path(api))).to \
            be < response.body.index(component_path(component))
        end

        it "returns results sorted by kind descending" do
          get search_path, params: { q: "Sort Test", s: "kind desc" }

          expect(response.body.index(component_path(component))).to \
            be < response.body.index(api_path(api))
        end
      end

      context "when paginating results" do
        before do
          create_list(:api, 30)
          sign_in_user_with_permissions([ "junction.codes/apis.all.read" ])
        end

        it "respects the per_page parameter" do
          get search_path, params: { q: "API Name", per_page: 10 }

          expect(response.body.scan(/<tr/).count).to eq(11)
        end
      end

      context "when the user has no read permission for an entity" do
        let!(:component) { create(:component) }

        before { sign_in_user_with_permissions(%w[junction.codes/apis.all.read]) }

        it "excludes entities of that type from results" do
          get search_path, params: { q: component.title }
          expect(response.body).not_to include(component_path(component))
        end
      end
    end

    describe "GET /search/autocomplete" do
      before { sign_in_user_with_permissions(%w[junction.codes/apis.all.read]) }

      it "returns http success" do
        get search_autocomplete_path, params: { q: "" }
        expect(response).to be_successful
      end

      context "with a matching query" do
        let!(:api) { create(:api) }

        it "includes the matching entity name" do
          get search_autocomplete_path, params: { q: api.title }
          expect(response.body).to include(api.title)
        end
      end

      context "when more than 5 entities match across multiple models" do
        before do
          sign_in_user_with_permissions(%w[
            junction.codes/apis.all.read
            junction.codes/components.all.read
            junction.codes/domains.all.read
          ])

          2.times { |i| create(:api, title: "GlobalSearch API #{i}") }
          2.times { |i| create(:component, title: "GlobalSearch Component #{i}") }
          2.times { |i| create(:domain, title: "GlobalSearch Domain #{i}") }
        end

        it "returns no more than 5 result links plus the see-all link" do
          get search_autocomplete_path, params: { q: "GlobalSearch" }

          # 5 entities + 1 "see all" link
          expect(response.body.scan(/<a /).count).to eq(6)
        end
      end

      context "when no entities match the query" do
        it "returns an empty turbo frame body" do
          get search_autocomplete_path, params: { q: "zzznomatch_#{SecureRandom.hex}" }
          expect(response.body).not_to include("<a ")
        end
      end
    end
  end
end
