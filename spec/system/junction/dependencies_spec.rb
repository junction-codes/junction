# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Dependencies", :js, type: :system do
  let(:component) { create(:component, title: "Checkout Service") }

  before do
    create(:component, title: "Billing Service")
    sign_in_with_permissions(
      %w[junction.codes/dashboards.all.read junction.codes/apis.all.read
         junction.codes/components.all.read junction.codes/components.all.write
         junction.codes/resources.all.read]
    )
    visit component_path(component)

    within("turbo-frame#dependencies") { click_button "Add Dependency" }
    within("dialog") do
      fill_in "Search", with: "Billing"
      within("turbo-frame#dependency-search-results") do
        find("li[role='option']", text: "Billing Service").click
      end
      click_button "Add Dependency"
    end
  end

  it "shows the new dependency in the table without a manual reload" do
    expect(page).to have_css("turbo-frame#dependencies", text: "Billing Service")
  end

  it "keeps the dependencies table populated" do
    expect(page).to have_css("turbo-frame#dependencies table")
  end
end
