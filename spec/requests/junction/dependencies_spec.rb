# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/dependencies", type: :request do
  describe "GET /apis/:id/dependencies" do
    it_behaves_like "a dependency index action",
      :api, :api_dependencies_path, :api_dependencies_url,
      "junction.codes/apis.all.read"
  end

  describe "GET /components/:id/dependencies" do
    it_behaves_like "a dependency index action",
      :component, :component_dependencies_path, :component_dependencies_url,
      "junction.codes/components.all.read"
  end

  describe "GET /resources/:id/dependencies" do
    it_behaves_like "a dependency index action",
      :resource, :resource_dependencies_path, :resource_dependencies_url,
      "junction.codes/resources.all.read"
  end

  describe "DELETE /dependencies/:id (source: api)" do
    it_behaves_like "a dependency deletion action",
      :api, "junction.codes/apis.all.write"
  end

  describe "DELETE /dependencies/:id (source: component)" do
    it_behaves_like "a dependency deletion action",
      :component, "junction.codes/components.all.write"
  end

  describe "DELETE /dependencies/:id (source: resource)" do
    it_behaves_like "a dependency deletion action",
      :resource, "junction.codes/resources.all.write"
  end

  describe "POST /apis/:id/dependencies" do
    it_behaves_like "a dependency creation action",
      :api, :api_dependencies_path, "junction.codes/apis.all.write"
  end

  describe "POST /components/:id/dependencies" do
    it_behaves_like "a dependency creation action",
      :component, :component_dependencies_path, "junction.codes/components.all.write"
  end

  describe "POST /resources/:id/dependencies" do
    it_behaves_like "a dependency creation action",
      :resource, :resource_dependencies_path, "junction.codes/resources.all.write"
  end

  describe "GET /apis/:id/dependencies/search" do
    it_behaves_like "a dependency search action",
      :api, :search_api_dependencies_path, "junction.codes/apis.all.read"
  end

  describe "GET /components/:id/dependencies/search" do
    it_behaves_like "a dependency search action",
      :component, :search_component_dependencies_path, "junction.codes/components.all.read"
  end

  describe "GET /resources/:id/dependencies/search" do
    it_behaves_like "a dependency search action",
      :resource, :search_resource_dependencies_path, "junction.codes/resources.all.read"
  end

  describe "GET /apis/:id/dependencies/search (viewable scope)" do
    subject!(:source) { create(:api) }

    let(:path) { search_api_dependencies_path(source) }

    context "when the user has owned.read for a target entity type" do
      let!(:owned_component) { create(:component, owner: user.groups.first) }
      let!(:other_component) { create(:component) }
      let(:user) do
        create_user_with_permissions(%w[
          junction.codes/apis.all.read
          junction.codes/components.owned.read
        ])
      end

      before do
        sign_in(user:, password: user.password)
      end

      it "includes components owned by the user's groups" do
        get path, params: { q: "" }
        expect(response.body).to include(owned_component.name)
      end

      it "excludes components not owned by the user's groups" do
        get path, params: { q: "" }
        expect(response.body).not_to include(other_component.name)
      end
    end

    context "when the user has no read permission for a target entity type" do
      let!(:resource_target) { create(:resource) }
      let(:user) do
        create_user_with_permissions(%w[
          junction.codes/apis.all.read
          junction.codes/components.all.read
        ])
      end

      before do
        sign_in(user:, password: user.password)
      end

      it "excludes entities of that type from the results" do
        get path, params: { q: resource_target.name }
        expect(response.body).not_to include(resource_target.name)
      end
    end
  end
end
