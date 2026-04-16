# frozen_string_literal: true

require "rails_helper"

require "junction/path_helper_overrides"

RSpec.describe Junction::PathHelperOverrides do
  describe ".catalog_model_class" do
    it "returns Junction::Component for :component" do
      expect(described_class.catalog_model_class(:component)).to eq(Junction::Component)
    end

    it "returns Junction::Api for :api" do
      expect(described_class.catalog_model_class(:api)).to eq(Junction::Api)
    end
  end

  describe ".namespace_name_kwargs" do
    it "uses attribute_in_database for ActiveRecord so unsaved slug changes do not affect URLs" do
      record = create(:component, title: "Stable", namespace: "acme", name: "widget")
      record.name = "tampered"
      record.namespace = "tampered"

      expect(described_class.namespace_name_kwargs(record)).to eq(
        namespace: "acme",
        name: "widget"
      )
    end

    it "falls back to reader methods when the record does not support attribute_in_database" do
      record = Struct.new(:namespace, :name).new("ns", "svc")

      expect(described_class.namespace_name_kwargs(record)).to eq(
        namespace: "ns",
        name: "svc"
      )
    end
  end

  describe ".apply!" do
    it "does not raise when invoked repeatedly on the same route set" do
      route_set = Junction::Engine.routes

      expect { 2.times { described_class.apply!(route_set) } }.not_to raise_error
    end
  end

  describe "prepended route helpers" do
    subject(:helper) do
      Class.new do
        include Junction::Engine.routes.url_helpers
      end.new
    end

    let(:url_helpers) { Junction::Engine.routes.url_helpers }

    before { described_class.apply!(Junction::Engine.routes) }

    describe "catalog member path helpers" do
      it "accepts a single model argument for component_path" do
        record = create(:component, title: "C", namespace: "org", name: "svc")

        slug_call = helper.component_path(namespace: "org", name: "svc")
        model_call = helper.component_path(record)

        expect(model_call).to eq(slug_call)
      end

      it "accepts a single model argument for edit_component_path" do
        record = create(:component, title: "C", namespace: "org", name: "svc")

        expect(helper.edit_component_path(record))
          .to eq(helper.edit_component_path(namespace: "org", name: "svc"))
      end

      it "merges extra keyword options when given a model" do
        record = create(:api, title: "A", namespace: "x", name: "y")

        expect(helper.api_path(record, format: :json))
          .to eq(helper.api_path(namespace: "x", name: "y", format: :json))
      end

      it "passes through non-model call shapes unchanged" do
        expect(helper.domain_path(namespace: "d", name: "p"))
          .to eq(url_helpers.domain_path(namespace: "d", name: "p"))
      end
    end

    describe "catalog member URL helpers" do
      it "accepts a single model argument for component_url" do
        record = create(:component, title: "C", namespace: "org", name: "svc")

        expect(helper.component_url(record, host: "www.example.test", protocol: "https"))
          .to eq(helper.component_url(namespace: "org", name: "svc", host: "www.example.test", protocol: "https"))
      end
    end

    describe "nested slug helpers" do
      it "accepts a single System for system_apis_path" do
        system = create(:system, title: "S", namespace: "co", name: "core")

        expect(helper.system_apis_path(system))
          .to eq(helper.system_apis_path(namespace: "co", name: "core"))
      end

      it "accepts a single Domain for domain_systems_path" do
        domain = create(:domain, title: "D", namespace: "corp", name: "plat")

        expect(helper.domain_systems_path(domain))
          .to eq(helper.domain_systems_path(namespace: "corp", name: "plat"))
      end

      it "accepts a single Group for group_members_path" do
        group = create(:group, title: "G", namespace: "def", name: "admins")

        expect(helper.group_members_path(group))
          .to eq(helper.group_members_path(namespace: "def", name: "admins"))
      end

      it "accepts a single Group for search_group_members_path" do
        group = create(:group, title: "G", namespace: "def", name: "ops")

        expect(helper.search_group_members_path(group))
          .to eq(helper.search_group_members_path(namespace: "def", name: "ops"))
      end
    end

    describe "group_member_path and group_member_url" do
      let(:group) { create(:group, title: "G", namespace: "g", name: "team") }
      let(:user) { create(:user, title: "U", namespace: "g", name: "member") }

      it "accepts group and user records" do
        expect(helper.group_member_path(group, user))
          .to eq(helper.group_member_path(namespace: "g", name: "team", id: user.id))
      end

      it "accepts a raw member id as the second argument" do
        expect(helper.group_member_path(group, 99))
          .to eq(helper.group_member_path(namespace: "g", name: "team", id: 99))
      end

      it "delegates group_member_url the same way" do
        expect(helper.group_member_url(group, user, host: "www.example.test", protocol: "https"))
          .to eq(
            helper.group_member_url(namespace: "g", name: "team", id: user.id,
                                    host: "www.example.test", protocol: "https")
          )
      end

      it "passes through when the first argument is not a Group" do
        expect(helper.group_member_path("g", "team", 1))
          .to eq(url_helpers.group_member_path("g", "team", 1))
      end
    end
  end
end
