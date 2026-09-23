# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction catalog tag and label filters", :js, type: :system do
  before do
    create(:component, title: "payments-api", tags: %w[payments go],
                       labels: { "team" => "atlas", "runtime" => "go1.22" })
    create(:component, title: "checkout-web", tags: %w[payments],
                       labels: { "team" => "nova" })
    create(:component, title: "legacy-billing", tags: [], labels: {})
    sign_in_with_permissions(%w[junction.codes/components.all.read])
    visit components_path
    page.has_text?("legacy-billing")
  end

  def within_menu(&)
    within("[data-ruby-ui--dropdown-menu-target='content']", visible: true, &)
  end

  # Opens the add-filter menu and steps into one of its panes.
  #
  # @param pane [String] "Tags" or "Labels".
  def open_pane(pane)
    click_button "+ Add filter"
    within_menu { click_button pane }
  end

  # Picks one value and waits for the chip it makes, so a second pick acts on
  # the reloaded page rather than the old one.
  def add_filter(pane, value, chip)
    open_pane(pane)
    within_menu { click_link value }
    page.has_text?(chip)
  end

  it "filters by a tag chosen from the menu" do
    add_filter("Tags", "payments", "Tag: payments")

    expect(page).to have_no_text("legacy-billing")
  end

  it "names the tag on a chip" do
    open_pane("Tags")
    within_menu { click_link "payments" }

    expect(page).to have_text("Tag: payments")
  end

  it "narrows further with a second tag" do
    add_filter("Tags", "payments", "Tag: payments")
    add_filter("Tags", "go", "Tag: go")

    expect(page).to have_no_text("checkout-web")
  end

  it "filters by a label value" do
    open_pane("Labels")
    within_menu { click_button "team" }
    within_menu { click_link "atlas" }

    expect(page).to have_text("Label: team = atlas")
  end

  it "filters by a label that is not set" do
    add_filter("Labels", "(not set)", "not set")

    expect(page).to have_no_text("payments-api")
  end

  it "says which entity has no such label" do
    add_filter("Labels", "(not set)", "not set")

    expect(page).to have_text("legacy-billing")
  end

  it "drops a chip again" do
    add_filter("Tags", "payments", "Tag: payments")
    click_link "Remove the payments tag filter"

    expect(page).to have_text("legacy-billing")
  end

  describe "the labels pane" do
    before { open_pane("Labels") }

    it "shows one key's values at a time" do
      within_menu { click_button "team" }

      expect(page).to have_link("atlas")
    end

    it "hides the other keys' values" do
      within_menu { click_button "team" }

      expect(page).to have_no_link("go1.22")
    end

    it "previews the chip a value would make" do
      within_menu { click_button "team" }
      within_menu { find("a", text: "atlas").hover }

      expect(page).to have_text("Label: team = atlas")
    end

    it "paints the preview as a chip" do
      within_menu { click_button "team" }
      background = page.evaluate_script(<<~JS)
        getComputedStyle(
          document.querySelector("[data-filter-menu-target='preview']")
        ).backgroundColor
      JS

      expect(background).not_to eq("rgba(0, 0, 0, 0)")
    end

    it "goes back to the filters" do
      within_menu { click_button "Back to filters" }

      expect(page).to have_link("Lifecycle")
    end
  end
end
