# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/dependents", type: :request do
  describe "GET /apis/:id/dependents" do
    it_behaves_like "a dependent index action",
      :api, :api_dependents_path, :api_dependents_url,
      "junction.codes/apis.all.read"
  end

  describe "GET /components/:id/dependents" do
    it_behaves_like "a dependent index action",
      :component, :component_dependents_path, :component_dependents_url,
      "junction.codes/components.all.read"
  end

  describe "GET /resources/:id/dependents" do
    it_behaves_like "a dependent index action",
      :resource, :resource_dependents_path, :resource_dependents_url,
      "junction.codes/resources.all.read"
  end
end
