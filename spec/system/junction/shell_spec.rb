# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction shell", :js, type: :system do
  let(:collapsed_width) { 72 }
  let(:expanded_width) { 264 }
  let(:rail) { "#junction-sidebar" }
  let(:toggle) { "[data-sidebar-target='toggle']" }

  before do
    sign_in_with_permissions(%w[
      junction.codes/dashboards.all.read
      junction.codes/components.all.read
      junction.codes/components.all.write
    ])
    visit components_path
    wait_for_sidebar
  end

  # Stimulus attaches the toggle's click listener on connect, and a click
  # dispatched before that is dropped with no sign of it.
  #
  # Stimulus reflects a value back onto its data attribute, and the server does
  # not render this one, so its presence means the controller has run.
  def wait_for_sidebar
    expect(page).to have_css("[data-controller='sidebar']" \
                             "[data-sidebar-collapsed-value]", visible: :all)
  end

  # Collapsing the rail slides the top bar to the left over 300ms, and the
  # toggle rides along inside it. The class lands immediately but the geometry
  # does not, so a click issued straight afterwards is aimed at where the button
  # used to be and hits nothing. Wait for the width to settle.
  def collapse_rail
    find(toggle).click
    wait_for_rail_width(collapsed_width)
  end

  def wait_for_rail_width(width)
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until rail_width == width
    end
  end

  def rail_width
    page.evaluate_script(
      "document.querySelector('#{rail}').getBoundingClientRect().width"
    )
  end

  describe "the navigation rail" do
    it "marks the listing being viewed" do
      expect(page).to have_css("#{rail} a[aria-current='page']",
                               text: "Components")
    end

    it "does not mark the other rows" do
      expect(page).to have_no_css("#{rail} a[aria-current='page']",
                                  text: "Home")
    end

    it "carries the number of components beside the row" do
      create(:component)

      visit components_path
      wait_for_sidebar

      expect(find("#{rail} a[aria-current='page']").text)
        .to include(Junction::Component.count.to_s)
    end
  end

  describe "collapsing the rail" do
    before { collapse_rail }

    it "narrows the rail" do
      expect(page).to have_css("#{rail}.w-18")
    end

    # The label is the row's accessible name. Hiding it outright would leave a
    # screen reader with a row of unnamed icons, so it is only hidden visually.
    it "keeps the labels in the accessibility tree" do
      expect(page).to have_css("#{rail} [data-sidebar-label].sr-only",
                               text: "Components", visible: :all)
    end

    it "names the rows for the pointer instead" do
      expect(page).to have_css("#{rail} a[title='Components']")
    end

    it "stays collapsed across a navigation" do
      visit dashboard_path
      wait_for_sidebar

      expect(page).to have_css("#{rail}.w-18")
    end

    it "expands again" do
      find(toggle).click
      wait_for_rail_width(expanded_width)

      expect(page).to have_css("#{rail}.w-66")
    end

    it "tells assistive tech whether the rail is open" do
      expect(page).to have_css("#{toggle}[aria-expanded='false']")
    end

    describe "the search button" do
      before { find("[data-sidebar-target='searchButton']").click }

      it "expands the rail" do
        wait_for_rail_width(expanded_width)

        expect(page).to have_css("#{rail}.w-66")
      end

      it "focuses the search field" do
        expect(page).to have_css("input[type='search']:focus")
      end
    end
  end

  describe "the account menu" do
    before { find("[aria-label='Open the account menu']").click }

    it "offers a way out" do
      expect(page).to have_link("Sign out")
    end

    it "starts on the system theme" do
      expect(page).to have_css("[role='radio'][data-theme='system']" \
                               "[aria-checked='true']")
    end

    context "when dark is chosen" do
      before { find("[role='radio'][data-theme='dark']").click }

      it "darkens the page" do
        expect(page).to have_css("html.dark", visible: :all)
      end

      it "marks the choice" do
        expect(page).to have_css("[role='radio'][data-theme='dark']" \
                                 "[aria-checked='true']")
      end

      it "survives a navigation" do
        visit dashboard_path
        wait_for_sidebar

        expect(page).to have_css("html.dark", visible: :all)
      end

      it "goes back to following the system" do
        find("[role='radio'][data-theme='system']").click

        expect(page.evaluate_script("localStorage.theme")).to be_nil
      end
    end
  end

  describe "the New menu" do
    it "offers the kinds the user may create" do
      click_button "New"

      expect(page).to have_link("Component")
    end

    it "omits the kinds they may not" do
      click_button "New"

      expect(page).to have_no_link("Domain")
    end
  end
end
