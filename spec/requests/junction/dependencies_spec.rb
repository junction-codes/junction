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
end
