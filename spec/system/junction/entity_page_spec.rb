# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction entity page", :js, type: :system do
  let(:component) { create(:component, title: "Checkout Service") }

  before do
    sign_in_with_permissions(%w[
      junction.codes/components.all.read
      junction.codes/apis.all.read
    ])
  end

  def open_page(query = {})
    visit component_path(component, **query)
    expect(page).to have_css("h1", text: "Checkout Service")
  end

  def open_tab_and_wait(label, value)
    click_button label
    expect(page).to have_current_path(/tab=#{value}/)
  end

  it "opens on the overview" do
    open_page

    expect(page).to have_css("h2", text: "Tags & labels")
  end

  it "keeps the open tab in the URL" do
    open_page
    click_button "Annotations"

    expect(page).to have_current_path(/tab=annotations/)
  end

  it "reopens that tab on reload" do
    open_page
    open_tab_and_wait("Annotations", "annotations")
    page.refresh

    expect(page).to have_css("[data-value='annotations'][data-state='active']")
  end

  it "drops the overview from the URL" do
    open_page(tab: "annotations")
    click_button "Overview"

    expect(page).to have_current_path(component_path(component))
  end

  describe "when the default tab is not the first" do
    before do
      open_page
      page.execute_script(<<~JS)
        document.querySelector("[data-controller='ruby-ui--tabs']")
               .setAttribute("data-ruby-ui--tabs-default-value", "annotations")
      JS
      click_button "Annotations"
      page.has_css?("[data-value='annotations'][data-state='active']")
    end

    it "leaves the new default out of the URL" do
      expect(page).to have_current_path(component_path(component))
    end

    it "puts the first tab in the URL, since it is no longer the default" do
      click_button "Overview"

      expect(page).to have_current_path(/tab=overview/)
    end
  end

  it "falls back to the overview for a tab the page does not have" do
    open_page(tab: "nonsense")

    expect(page).to have_css("[data-value='overview'][data-state='active']")
  end

  it "opens the dependencies tab from the card's remainder" do
    create_list(:api, 5).each { |api| create(:relation, source: component, target: api) }
    open_page
    click_button "+ 1 more"

    expect(page).to have_css("[data-value='dependencies'][data-state='active']")
  end
end
