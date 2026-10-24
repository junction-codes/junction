# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::DependencyGraph", :js, type: :system do
  let(:component) { create(:component, title: "Checkout Service") }
  let(:api) { create(:api, title: "Billing API") }

  before do
    sign_in_with_permissions(
      %w[junction.codes/components.all.read junction.codes/apis.all.read]
    )
  end

  # Each node links to the entity it stands for, which is what identifies it.
  def node(entity)
    path = public_send(:"#{entity.model_name.element}_path", entity)

    find("[data-graph-target='node'][href='#{path}']")
  end

  # The graph is drawn into a tab that is display:none until it's opened.
  def open_graph
    visit component_path(component)
    click_on "Dependencies"
    click_on "Graph"
  end

  context "when the entity is joined to something" do
    before do
      create(:relation, source: component, target: api)
      open_graph
    end

    it "draws a node for the entity" do
      expect(node(component)).to have_text(component.name)
    end

    it "draws a node for what it depends on" do
      expect(node(api)).to have_text(api.name)
    end

    it "opens the entity a node names" do
      node(api).click

      expect(page).to have_css("h1", text: api.title)
    end

    it "marks the entity the page is about" do
      expect(node(component)[:class]).to include("border-accent-solid")
    end

    it "lays the nodes out once the tab is open" do
      expect(page).to have_css("[data-graph-laid-out='true']")
    end

    it "puts each node in its own place" do
      places = page.all("[data-graph-target='node']").map { |n| n[:style] }

      expect(places.uniq.size).to eq(places.size)
    end

    it "joins them with a line" do
      expect(page).to have_css("[data-graph-target='edges'] path[d]", visible: :all)
    end

    it "names what the lines mean" do
      expect(page).to have_text("depends on")
    end

    describe "the legend" do
      # Scoped to the graph: the kinds are named elsewhere on the page.
      let(:graph) { find("[data-controller='graph']") }

      it "names the kinds it drew" do
        expect(graph).to have_text("Component").and have_text("API")
      end

      it "leaves out the kinds it did not" do
        expect(graph).to have_no_text("Resource")
      end
    end

    it "marks the kind on a node showing the entity's own image" do
      expect(node(api).find("img")[:class]).to include("ring-kind-api-fg")
    end
  end

  context "when the reader may not open a neighbor" do
    let(:system) { create(:system, title: "Payments") }
    let(:component) { create(:component, title: "Checkout Service", system:) }

    before do
      create(:relation, source: component, target: api)
      open_graph
    end

    it "still draws the node" do
      expect(page).to have_css("[data-graph-target='node']", text: system.name)
    end

    it "does not link to it" do
      node = find("[data-graph-target='node']", text: system.name)

      expect(node.tag_name).to eq("div")
    end

    it "still links to the ones it may open" do
      expect(node(api).tag_name).to eq("a")
    end
  end

  context "when nothing is joined to the entity" do
    before { open_graph }

    it "says so" do
      expect(page).to have_text("Nothing depends on this component")
    end

    it "draws no nodes" do
      expect(page).to have_no_css("[data-graph-target='node']")
    end
  end
end
