# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Relation do
  subject(:relation) { build(:relation) }

  let(:component) { create(:component) }
  let(:api) { create(:api) }

  describe "validations" do
    it "is valid with a source, target, and type" do
      expect(relation).to be_valid
    end

    it "requires a relation type" do
      relation.relation_type = nil
      expect(relation).not_to be_valid
    end

    it "rejects an unknown relation type" do
      relation.relation_type = "invented"
      expect(relation).not_to be_valid
    end

    it "rejects an entity related to itself" do
      expect(build(:relation, source: component, target: component)).not_to be_valid
    end

    it "rejects a target of a kind that cannot be depended on" do
      expect(build(:relation, source: component, target: create(:system))).not_to be_valid
    end

    it "rejects a source of a kind that cannot be depended on" do
      expect(build(:relation, source: create(:system), target: api)).not_to be_valid
    end

    it "reports an undependable source on source_id" do
      relation = build(:relation, source: create(:system), target: api)
      relation.valid?

      expect(relation.errors[:source_id]).to be_present
    end
  end

  describe "uniqueness" do
    before { create(:relation, source: component, target: api) }

    it "rejects a duplicate edge" do
      duplicate = build(:relation, source: component, target: api)
      expect(duplicate).not_to be_valid
    end

    it "allows the same pair with a different relation type" do
      other = build(:relation, source: component, target: api,
                    relation_type: described_class::CONSUMES_API)
      expect(other).to be_valid
    end

    it "allows the reverse edge" do
      reverse = build(:relation, source: api, target: component)
      expect(reverse).to be_valid
    end
  end

  describe "#inverse_type" do
    it "names the relation as read from the target" do
      expect(relation.inverse_type).to eq("dependency_of")
    end

    it "names the inverse of provides_api" do
      relation.relation_type = described_class::PROVIDES_API
      expect(relation.inverse_type).to eq("api_provided_by")
    end
  end

  describe "distinguishing provided from consumed APIs" do
    let(:provides) do
      create(:relation, source: component, target: api,
             relation_type: described_class::PROVIDES_API)
    end

    let(:consumes) do
      create(:relation, source: component, target: create(:api),
             relation_type: described_class::CONSUMES_API)
    end

    it "keeps the provided API separate from the consumed one" do
      expect(described_class.provides_api).to contain_exactly(provides)
    end

    it "keeps the consumed API separate from the provided one" do
      expect(described_class.consumes_api).to contain_exactly(consumes)
    end
  end
end
