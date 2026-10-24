# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::DependencyGraphService do
  subject(:graph) { described_class.new(model: component).build }

  let(:system) { create(:system, title: "Payments") }
  let(:component) { create(:component, title: "Checkout", system:) }
  let(:api) { create(:api, title: "Payments API", system:) }

  before { create(:relation, source: component, target: api, relation_type: "depends_on") }

  def node_for(entity)
    graph[:nodes].find { |node| node[:record] == entity }
  end

  it "names the entity the page is about" do
    expect(graph[:current_node_id]).to eq("junction/component-#{component.id}")
  end

  it "carries the record each node stands for" do
    expect(node_for(api)).to be_present
  end

  it "reaches the entities one step away" do
    expect(graph[:nodes].map { |node| node[:record] }).to include(component, api, system)
  end

  it "marks a system as context rather than a step in the chain" do
    expect(node_for(system)[:aside]).to be(true)
  end

  it "leaves the entities the walk reached in the chain" do
    expect(node_for(api)[:aside]).to be(false)
  end

  context "when an entity is part of another through a stored relation" do
    let(:whole) { create(:component, title: "Platform") }

    before { create(:relation, source: component, target: whole, relation_type: "part_of") }

    it "keeps the entity the page is about in the chain" do
      expect(node_for(component)[:aside]).to be(false)
    end

    it "keeps what it is part of in the chain" do
      expect(node_for(whole)[:aside]).to be(false)
    end
  end

  describe "the edges" do
    def edge_between(source, target)
      graph[:edges].find do |edge|
        edge[:source].end_with?("-#{source.id}") && edge[:target].end_with?("-#{target.id}")
      end
    end

    it "carries the relation's own type" do
      expect(edge_between(component, api)[:type]).to eq("depends_on")
    end

    it "names a system's edge to what belongs to it" do
      expect(edge_between(system, component)[:type]).to eq("part_of")
    end
  end

  describe "the depth" do
    subject(:graph) { described_class.new(model: component, depth: 1).build }

    let(:far) { create(:resource, title: "Ledger DB") }

    before { create(:relation, source: api, target: far, relation_type: "depends_on") }

    it "reaches what is one step away" do
      expect(graph[:nodes].map { |node| node[:record] }).to include(api)
    end

    it "stops before what is two steps away" do
      expect(graph[:nodes].map { |node| node[:record] }).not_to include(far)
    end

    it "counts what it did not draw" do
      expect(graph[:beyond]).to be_positive
    end

    it "leaves out the edges it could not join" do
      ids = graph[:nodes].map { |node| node[:id] }

      expect(graph[:edges].flat_map { |edge| [ edge[:source], edge[:target] ] }).to all(be_in(ids))
    end
  end
end
