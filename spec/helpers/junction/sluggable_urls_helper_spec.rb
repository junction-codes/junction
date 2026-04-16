# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::SluggableUrlsHelper do
  subject(:helper) do
    Class.new do
      include Junction::Engine.routes.url_helpers
      include Junction::SluggableUrlsHelper
    end.new
  end

  describe "#junction_catalog_path" do
    it "returns the slug show path for a catalog record" do
      record = create(:component, title: "Widget", namespace: "acme", name: "widget")

      expect(helper.junction_catalog_path(record)).to eq("/components/acme/widget")
    end

    it "forwards extra options to the route helper" do
      record = create(:api, title: "API", namespace: "org", name: "billing")

      path = helper.junction_catalog_path(record, format: :json)

      expect(path).to eq("/apis/org/billing.json")
    end
  end

  describe "#junction_catalog_url" do
    it "returns a full URL when host options are given" do
      record = create(:resource, title: "DB", namespace: "team", name: "primary")

      url = helper.junction_catalog_url(record, host: "catalog.example.test", protocol: "https")

      expect(url).to eq("https://catalog.example.test/resources/team/primary")
    end
  end

  describe "#junction_edit_catalog_path" do
    it "returns the slug edit path" do
      record = create(:component, title: "Svc", namespace: "ns", name: "svc")

      expect(helper.junction_edit_catalog_path(record)).to eq("/components/ns/svc/edit")
    end
  end

  describe "#junction_catalog_form_url" do
    it "returns nil for nil" do
      expect(helper.junction_catalog_form_url(nil)).to be_nil
    end

    it "returns nil for a new (unpersisted) record" do
      record = build(:component, title: "Draft")

      expect(helper.junction_catalog_form_url(record)).to be_nil
    end

    it "returns the catalog path for a persisted record" do
      record = create(:component, title: "Live", namespace: "def", name: "live")

      expect(helper.junction_catalog_form_url(record)).to eq("/components/def/live")
    end
  end

  describe "#junction_dependency_graph_path" do
    it "returns the dependency graph path for apis, components, and resources" do
      component = create(:component, title: "C", namespace: "a", name: "c")

      expect(helper.junction_dependency_graph_path(component))
        .to eq("/components/a/c/dependency_graph")
    end

    it "raises for entity types without a dependency graph route" do
      role = create(:role)

      expect { helper.junction_dependency_graph_path(role) }
        .to raise_error(ArgumentError, /Unsupported dependency graph record/)
    end
  end

  describe "#junction_dependencies_path" do
    it "returns the nested dependencies path" do
      api = create(:api, title: "A", namespace: "x", name: "api")

      expect(helper.junction_dependencies_path(api)).to eq("/apis/x/api/dependencies")
    end

    it "merges options into the route helper" do
      resource = create(:resource, title: "R", namespace: "y", name: "db")

      expect(helper.junction_dependencies_path(resource, format: :json))
        .to eq("/resources/y/db/dependencies.json")
    end

    it "raises for unsupported record types" do
      role = create(:role)

      expect { helper.junction_dependencies_path(role) }
        .to raise_error(ArgumentError, /Unsupported dependencies record/)
    end
  end

  describe "#junction_dependents_path" do
    it "returns the nested dependents path" do
      api = create(:api, title: "A", namespace: "p", name: "q")

      expect(helper.junction_dependents_path(api)).to eq("/apis/p/q/dependents")
    end
  end

  describe "#junction_search_dependencies_path" do
    it "returns the search dependencies path" do
      component = create(:component, title: "C", namespace: "s", name: "c")

      expect(helper.junction_search_dependencies_path(component))
        .to eq("/components/s/c/dependencies/search")
    end
  end

  describe "#junction_apis_system_path and related system child paths" do
    it "delegates to system_apis_path with slug segments" do
      system = create(:system, title: "Sys", namespace: "org", name: "core")

      expect(helper.junction_apis_system_path(system)).to eq("/systems/org/core/apis")
    end

    it "delegates to system_components_path" do
      system = create(:system, title: "S", namespace: "n", name: "s")

      expect(helper.junction_components_system_path(system)).to eq("/systems/n/s/components")
    end

    it "delegates to system_resources_path" do
      system = create(:system, title: "S", namespace: "n", name: "s")

      expect(helper.junction_resources_system_path(system)).to eq("/systems/n/s/resources")
    end
  end

  describe "#junction_systems_domain_path" do
    it "delegates to domain_systems_path with slug segments" do
      domain = create(:domain, title: "Dom", namespace: "corp", name: "platform")

      expect(helper.junction_systems_domain_path(domain)).to eq("/domains/corp/platform/systems")
    end
  end

  describe "#junction_group_members_path and search" do
    it "delegates to group_members_path" do
      group = create(:group, title: "G", namespace: "def", name: "admins")

      expect(helper.junction_group_members_path(group)).to eq("/groups/def/admins/members")
    end

    it "delegates to search_group_members_path" do
      group = create(:group, title: "G", namespace: "def", name: "ops")

      expect(helper.junction_search_group_members_path(group))
        .to eq("/groups/def/ops/members/search")
    end
  end

  describe "#junction_group_member_path" do
    it "accepts a user record and passes its id" do
      group = create(:group, title: "G", namespace: "g", name: "team")
      user = create(:user, title: "U", namespace: "g", name: "alice")

      expect(helper.junction_group_member_path(group, user))
        .to eq("/groups/g/team/members/#{user.id}")
    end

    it "accepts a raw member id" do
      group = create(:group, title: "G", namespace: "g", name: "team")

      expect(helper.junction_group_member_path(group, 42)).to eq("/groups/g/team/members/42")
    end
  end
end
