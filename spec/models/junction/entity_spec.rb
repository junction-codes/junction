# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Entity do
  describe "the kind discriminator" do
    it "uses kind rather than type so type keeps its catalog meaning" do
      expect(described_class.inheritance_column).to eq("kind")
    end

    it "stores demodulized names" do
      expect(Junction::Api.sti_name).to eq("Api")
    end

    it "leaves type free for the catalog type vocabulary" do
      api = build(:api, type: "openapi")
      expect(api.type).to eq("openapi")
    end

    it "sets kind from the model class" do
      expect(build(:component).kind).to eq("Component")
    end
  end

  describe "#kind=" do
    it "rejects assignment that would change the kind" do
      expect { build(:component).kind = "User" }
        .to raise_error(ActiveRecord::ReadonlyAttributeError)
    end

    it "ignores assignment matching the model class" do
      component = build(:component)
      expect { component.kind = "Component" }.not_to raise_error
    end

    # Rails checks the inheritance column itself before the writer runs, so
    # mass assignment is refused by ActiveRecord's own STI guard rather than by
    # the writer. Either way it cannot mint an entity of another kind.
    it "is not assignable through mass assignment" do
      expect { Junction::Component.new(kind: "User") }
        .to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe "kind immutability" do
    subject(:component) { create(:component) }

    # The writer already refuses to change the kind, so reaching the validation
    # takes a low-level write. It is the backstop for exactly that case.
    it "is invalid when the kind is changed behind the writer's back" do
      component.send(:write_attribute, :kind, "Api")
      expect(component).not_to be_valid
    end

    it "reports the kind as immutable" do
      component.send(:write_attribute, :kind, "Api")
      component.valid?
      expect(component.errors[:kind]).to be_present
    end
  end

  describe ".sti_class_for" do
    it "resolves a registered core kind" do
      expect(described_class.sti_class_for("Api")).to eq(Junction::Api)
    end

    it "resolves a kind registered outside the Junction namespace" do
      stub_const("MyPlugin::Widget", Class.new(described_class))
      Junction::Kinds.register(:widget, model_name: "MyPlugin::Widget")

      expect(described_class.sti_class_for("Widget")).to eq(MyPlugin::Widget)
    ensure
      Junction::Kinds.reset!
    end
  end

  describe ".catalog" do
    it "excludes users" do
      create(:user)
      expect(described_class.catalog.where(kind: "User")).to be_empty
    end

    it "excludes groups" do
      create(:group)
      expect(described_class.catalog.where(kind: "Group")).to be_empty
    end

    it "excludes roles" do
      create(:role)
      expect(described_class.catalog.where(kind: "Role")).to be_empty
    end

    it "includes components" do
      component = create(:component)
      expect(described_class.catalog).to include(component)
    end
  end

  describe ".ransackable_attributes" do
    it "does not expose contact addresses" do
      expect(described_class.ransackable_attributes).not_to include("email")
    end

    it "does not expose the spec payload" do
      expect(described_class.ransackable_attributes).not_to include("spec")
    end

    it "does not expose the role reference" do
      expect(described_class.ransackable_attributes).not_to include("role_id")
    end

    it "exposes no associations by default" do
      expect(described_class.ransackable_associations).to be_empty
    end
  end

  # Every kind shares junction_entities, so name uniqueness has to be scoped by
  # kind explicitly. Without that scope ActiveRecord resolves the uniqueness
  # query against Junction::Entity, which carries no type condition, and a name
  # would silently become unique across the whole catalog.
  describe "slug uniqueness across kinds" do
    let(:group) { create(:group) }

    before { create(:component, name: "shared-name", owner: group) }

    it "allows another kind to use the same namespace and name" do
      domain = build(:domain, name: "shared-name", owner: group)
      expect(domain).to be_valid
    end

    it "persists both entities" do
      create(:domain, name: "shared-name", owner: group)
      expect(described_class.where(namespace: "default", name: "shared-name").count).to eq(2)
    end

    it "rejects a second entity of the same kind" do
      duplicate = build(:component, name: "shared-name", owner: group)
      expect(duplicate).not_to be_valid
    end

    it "reports the collision on name" do
      duplicate = build(:component, name: "shared-name", owner: group)
      duplicate.valid?
      expect(duplicate.errors[:name]).to be_present
    end

    it "allows the same name in another namespace" do
      other = build(:component, name: "shared-name", namespace: "staging", owner: group)
      expect(other).to be_valid
    end
  end

  describe ".ownable?" do
    it "is false for a kind with no owner" do
      expect(Junction::User).not_to be_ownable
    end

    it "is true for a kind that includes Ownable" do
      expect(Junction::Component).to be_ownable
    end

    it "is false on the base class" do
      expect(described_class).not_to be_ownable
    end
  end

  describe "#icon" do
    it "falls back to the kind's default when the type declares none" do
      expect(build(:user).icon).to eq("user-round")
    end

    it "uses the icon the catalog options give the type" do
      allow(Junction::CatalogOptions).to receive(:section).with(:components)
        .and_return({ "service" => { icon: "cloud" } }.with_indifferent_access)

      expect(build(:component, type: "service").icon).to eq("cloud")
    end
  end

  # Every kind shares one table, so anything a model allows Ransack to query
  # becomes a URL-driven query surface for that kind.
  describe "Ransack allowlists across kinds" do
    let(:forbidden) do
      %w[annotations labels links spec tags managed_by source_ref location_id
         password_digest]
    end

    let(:models) do
      Junction::Kinds.all.map(&:model) + [ Junction::Relation, Junction::GroupRole ]
    end

    it "exposes no forbidden attribute on any model" do
      leaked = models.to_h { |m| [ m.name, m.ransackable_attributes & forbidden ] }
                     .reject { |_, v| v.empty? }

      expect(leaked).to be_empty
    end

    it "exposes only real columns or aliases" do
      unknown = models.to_h do |model|
        known = model.column_names + model.attribute_aliases.keys
        [ model.name, model.ransackable_attributes - known ]
      end.reject { |_, v| v.empty? }

      expect(unknown).to be_empty
    end

    it "names only real associations" do
      unknown = models.to_h do |model|
        names = model.reflect_on_all_associations.map { |a| a.name.to_s }
        [ model.name, model.ransackable_associations - names ]
      end.reject { |_, v| v.empty? }

      expect(unknown).to be_empty
    end

    it "exposes nothing on credentials" do
      expect(Junction::Credential.ransackable_attributes).to be_empty
    end

    it "exposes no associations on credentials" do
      expect(Junction::Credential.ransackable_associations).to be_empty
    end
  end

  describe ".policy_class" do
    it "routes every kind through the entity policy" do
      expect(Junction::Api.policy_class).to eq(Junction::EntityPolicy)
    end
  end
end
