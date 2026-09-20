# frozen_string_literal: true

require "rails_helper"

# `overflow_title_controller` gives a cut value a way to be read in full. It's
# attached to whatever holds the values, so these cover the two places outside
# the catalog listing that truncate.
RSpec.describe "Junction overflow titles", :js, type: :system do
  let(:long_title) { "a-really-long-dependency-name-that-will-not-fit-in-its-column" }

  def title_of(selector)
    page.evaluate_script(
      "document.querySelector(\"#{selector}\")?.getAttribute('title')"
    )
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
      expect(title_of("a[href*='#{long_title}']")).to eq(long_title)
    end

    it "leaves a name that fits without one" do
      expect(title_of("a[href*='short-api']")).to be_nil
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
      expect(title_of("[data-controller='overflow-title'] a")).to eq(long_title)
    end
  end
end
