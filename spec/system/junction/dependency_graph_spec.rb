# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::DependencyGraph", :js, type: :system do
  let(:component) { create(:component, title: "Checkout Service") }

  before do
    create(:relation, source: component, target: create(:api, title: "Billing API"))
    sign_in_with_permissions(
      %w[junction.codes/components.all.read junction.codes/apis.all.read]
    )
    visit component_path(component)
  end

  it "renders the canvas into the graph container" do
    expect(page).to have_css("[data-graph-target='container'] canvas", visible: :all)
  end

  it "does not report a failure loading the graph" do
    expect(page).to have_no_text("Could not load dependency graph.")
  end
end
