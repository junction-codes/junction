# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Kinds do
  let(:persisted_contexts) do
    %w[apis components domains groups resources roles systems users]
  end

  describe "the core registrations" do
    it "registers every core kind" do
      expect(described_class.names).to include(
        "Api", "Component", "Domain", "System", "Resource",
        "Group", "User", "Role", "Template", "Location"
      )
    end

    it "derives contexts matching those persisted before the refactor" do
      expect(described_class.contexts).to include(*persisted_contexts)
    end

    it "excludes auth principals and RBAC config from the catalog" do
      expect(described_class.catalog_names).not_to include("User", "Group", "Role")
    end

    it "includes catalog kinds in the catalog" do
      expect(described_class.catalog_names).to include(
        "Api", "Component", "Domain", "System", "Resource"
      )
    end

    it "does not expose kinds that have no controllers yet" do
      expect(described_class.exposed.map(&:name)).not_to include("Template", "Location")
    end

    it "still registers unexposed kinds so their rows resolve" do
      expect(described_class.model_for("Location")).to eq(Junction::Location)
    end

    it "keeps unexposed kinds out of the catalog" do
      expect(described_class.catalog_names).not_to include("Template", "Location")
    end

    it "keeps unexposed kinds unrouted" do
      expect(described_class.sluggable.map(&:name)).not_to include("Template", "Location")
    end

    it "marks only relation-capable kinds as dependable" do
      expect(described_class.dependable_names).to contain_exactly(
        "Api", "Component", "Resource"
      )
    end
  end

  describe ".for" do
    it "looks a kind up by its STI name" do
      expect(described_class.for("Api").scope).to eq(:api)
    end

    it "returns nil for an unregistered name" do
      expect(described_class.for("Nope")).to be_nil
    end

    it "ignores case, so a Backstage kind string resolves" do
      expect(described_class.for("API").name).to eq("Api")
    end

    it "matches a lowercased kind, as an entity reference carries it" do
      expect(described_class.for("component").name).to eq("Component")
    end
  end

  describe ".by_context" do
    it "looks a kind up by its permission context" do
      expect(described_class.by_context("components").name).to eq("Component")
    end

    it "returns nil for an unregistered context" do
      expect(described_class.by_context("nope")).to be_nil
    end
  end

  describe ".by_scope" do
    it "looks a kind up by its singular scope" do
      expect(described_class.by_scope(:domain).name).to eq("Domain")
    end

    it "accepts a string scope" do
      expect(described_class.by_scope("domain").name).to eq("Domain")
    end
  end

  describe ".model_for" do
    it "resolves a registered kind to its model class" do
      expect(described_class.model_for("Api")).to eq(Junction::Api)
    end

    it "returns nil for an unregistered name so STI can fall back" do
      expect(described_class.model_for("Nope")).to be_nil
    end
  end

  describe ".ownable?" do
    it "is true for a context whose kind has an owner" do
      expect(described_class).to be_ownable("apis")
    end

    it "is false for a context whose kind has no owner" do
      expect(described_class).not_to be_ownable("groups")
    end

    it "is false for an unregistered context" do
      expect(described_class).not_to be_ownable("nope")
    end
  end

  describe ".register" do
    after { described_class.reset! }

    it "adds a new kind" do
      described_class.register(:widget, model_name: "MyPlugin::Widget")
      expect(described_class.for("Widget").model_name).to eq("MyPlugin::Widget")
    end

    it "raises when another model has already claimed the scope" do
      described_class.register(:widget, model_name: "MyPlugin::Widget")

      expect { described_class.register(:widget, model_name: "Other::Widget") }
        .to raise_error(ArgumentError, /already registered to MyPlugin::Widget/)
    end

    it "refuses a plugin model claiming a core kind's scope" do
      expect { described_class.register(:component, model_name: "MyPlugin::Component") }
        .to raise_error(ArgumentError, /already registered to Junction::Component/)
    end

    it "lets the same model register again, as a code reload does" do
      described_class.register(:widget, model_name: "MyPlugin::Widget")

      expect { described_class.register(:widget, model_name: "MyPlugin::Widget") }
        .not_to raise_error
    end

    it "does not duplicate the entry when re-registering" do
      described_class.register(:widget, model_name: "MyPlugin::Widget")
      described_class.register(:widget, model_name: "MyPlugin::Widget")

      expect(described_class.names.count { |name| name == "Widget" }).to eq(1)
    end

    it "lets a core kind's flags be overridden" do
      described_class.register(:location, catalog: true, exposed: true)

      expect(described_class.exposed.map(&:name)).to include("Location")
    end
  end

  describe ".reset!" do
    it "restores the core registrations" do
      described_class.register(:widget, model_name: "MyPlugin::Widget")
      described_class.reset!
      expect(described_class.for("Widget")).to be_nil
    end

    it "keeps core kinds registered" do
      described_class.reset!
      expect(described_class.for("Api")).not_to be_nil
    end
  end
end
