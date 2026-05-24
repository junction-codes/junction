# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Options::Overview do
  describe "#fields" do
    subject(:fields) { described_class.new.fields }

    before do
      allow(Junction::CatalogOptions).to receive(:options).and_return(
        {
          apis: {
            "openapi" => { name: "OpenAPI", icon: "webhook" },
            "graphql" => { name: "GraphQL", icon: "webhook" }
          },
          kinds: {
            "web" => { name: "Web Service", icon: "globe" }
          },
          resources: {
            "queue" => { name: "Queue", icon: "rows-4" }
          },
          group_types: {
            "team" => { name: "Team", icon: "users-round" }
          },
          lifecycles: {
            "stable" => { name: "Stable", icon: "badge-check" },
            "experimental" => { name: "Experimental", icon: "flask-conical" }
          }
        }.with_indifferent_access
      )

      create(:api, api_type: "openapi", lifecycle: "stable")
      create(:api, api_type: "custom_type", lifecycle: "legacy")
      create(:component, component_type: "web", lifecycle: "stable")
    end

    it "returns the configured option fields" do
      expect(fields.map { |field| field[:id] }).to eq(%w[
          api_type
          component_type
          resource_type
          group_type
          lifecycle
        ])
    end

    it "uses explicit i18n field label for api_type" do
      labels = fields.to_h { |field| [ field[:id], field[:label] ] }

      expect(labels["api_type"]).to eq("API Type")
    end

    it "uses explicit i18n field label for component_type" do
      labels = fields.to_h { |field| [ field[:id], field[:label] ] }

      expect(labels["component_type"]).to eq("Component Type")
    end

    it "uses explicit i18n field label for resource_type" do
      labels = fields.to_h { |field| [ field[:id], field[:label] ] }

      expect(labels["resource_type"]).to eq("Resource Type")
    end

    it "uses explicit i18n field label for group_type" do
      labels = fields.to_h { |field| [ field[:id], field[:label] ] }

      expect(labels["group_type"]).to eq("Group Type")
    end

    it "uses explicit i18n field label for lifecycle" do
      labels = fields.to_h { |field| [ field[:id], field[:label] ] }

      expect(labels["lifecycle"]).to eq("Lifecycle")
    end

    it "includes known options with zero counts" do
      api_field = fields.find { |field| field[:id] == "api_type" }
      graphql = api_field[:known].find { |option| option[:value] == "graphql" }

      expect(graphql[:count]).to eq(0)
    end

    it "includes arbitrary values in other options" do
      api_field = fields.find { |field| field[:id] == "api_type" }

      expect(api_field[:other].map { |option| option[:value] }).to include("custom_type")
    end

    it "aggregates lifecycle counts across apis and components" do
      lifecycle_field = fields.find { |field| field[:id] == "lifecycle" }
      stable = lifecycle_field[:known].find { |option| option[:value] == "stable" }

      expect(stable[:count]).to eq(2)
    end

    it "limits value breakdown charts to top five values" do
      ("a".."f").each do |letter|
        create(:api, api_type: letter * 3)
      end

      api_field = described_class.new.fields.find { |field| field[:id] == "api_type" }

      expect(api_field.dig(:charts, :value_breakdown).size).to eq(5)
    end
  end
end
