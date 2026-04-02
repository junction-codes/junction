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
          get search_path, params: { q: api.name }
          expect(response.body).to include(api.name)
        end
      end

      context "when the user only has owned.read for a model" do
        let(:user) { create_user_with_permissions(%w[junction.codes/apis.owned.read]) }
        let!(:owned_api) { create(:api, owner: user.groups.first) }
        let!(:other_api) { create(:api) }

        before { sign_in(user:, password: user.password) }

        it "includes apis owned by the user's group" do
          get search_path, params: { q: owned_api.name }
          expect(response.body).to include(owned_api.name)
        end

        it "excludes apis not owned by the user's group" do
          get search_path, params: { q: other_api.name }
          expect(response.body).not_to include(api_path(other_api))
        end
      end

      context "when the user has no read permission for an entity" do
        let!(:component) { create(:component) }

        before { sign_in_user_with_permissions(%w[junction.codes/apis.all.read]) }

        it "excludes entities of that type from results" do
          get search_path, params: { q: component.name }
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
          get search_autocomplete_path, params: { q: api.name }
          expect(response.body).to include(api.name)
        end
      end

      context "when more than 5 entities match" do
        before { create_list(:api, 6) }

        it "returns no more than 5 result links" do
          get search_autocomplete_path, params: { q: "" }
          expect(response.body.scan(/<a /).count).to be <= 6
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
