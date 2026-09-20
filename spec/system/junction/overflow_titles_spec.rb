# frozen_string_literal: true

require "rails_helper"

# `overflow_title_controller` gives a cut value a way to be read in full. It's
# attached to whatever holds the values, so these cover the two places outside
# the catalog listing that truncate.
RSpec.describe "Junction overflow titles", :js, type: :system do
  let(:long_title) { "a-really-long-dependency-name-that-will-not-fit-in-its-column" }

  # Capybara retries these, which is what waits for the controller: the title
  # is written by Stimulus, and on the entity page only once the tab pane is
  # visible, so asserting on the server's HTML would race it.
  def expect_title(selector, title)
    expect(page).to have_css("#{selector}[title='#{title}']")
  end

  # `:not([title])` still requires the element itself, so a row that stopped
  # rendering fails rather than passing for the wrong reason.
  def expect_no_title(selector)
    expect(page).to have_css("#{selector}:not([title])")
  end

  describe "the entity page's cards" do
    let(:component) { create(:component, title: "Checkout Service") }

    before do
      create(:relation, source: component, target: create(:api, title: long_title))
      create(:relation, source: component, target: create(:api, title: "short-api"))
      sign_in_with_permissions(%w[junction.codes/components.all.read
                                  junction.codes/apis.all.read])
      visit component_path(component)
      page.has_css?("h2", text: "Dependencies")
    end

    it "offers the whole value on a name that was cut" do
      expect_title("a[href*='#{long_title}']", long_title)
    end

    it "leaves a name that fits without one" do
      expect_no_title("a[href*='short-api']")
    end
  end

  describe "a container that does not clip" do
    let(:component) do
      create(:component, title: "Checkout Service", tags: [ "a" * 63 ])
    end

    before do
      sign_in_with_permissions(%w[junction.codes/components.all.read])
      visit component_path(component)
      page.has_css?("h2", text: "Tags & labels")
      page.current_window.resize_to(520, 800)
    end

    it "is left alone, however wide its contents" do
      expect(page.evaluate_script(<<~JS)).to eq([])
        [...document.querySelectorAll("[data-controller='overflow-title'] [title]")]
          .filter((el) => getComputedStyle(el).overflowX === "visible")
          .map((el) => el.tagName + ": " + el.getAttribute("title").slice(0, 30))
      JS
    end
  end

  describe "the dashboard's recent updates" do
    before do
      create(:component, title: long_title)
      sign_in_with_permissions(%w[junction.codes/dashboards.all.read
                                  junction.codes/components.all.read])
      visit dashboard_path
      page.has_text?("Recent catalog updates")
    end

    it "offers the whole value on a name that was cut" do
      expect_title("[data-controller='overflow-title'] a", long_title)
    end
  end
end
