# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction catalog listing", :js, type: :system do
  let(:group) { create(:group, title: "Payments Platform") }

  let!(:api) do
    create(:component, title: "payments-api", owner: group,
                       lifecycle: "production", tags: %w[payments go platform])
  end

  let!(:legacy) do
    create(:component, title: "legacy-billing", lifecycle: "deprecated",
                       tags: [])
  end

  before do
    sign_in_with_permissions(%w[
      junction.codes/components.all.read
      junction.codes/groups.all.read
    ])
    visit components_path
  end

  def within_menu(&)
    within("[data-ruby-ui--dropdown-menu-target='content']", visible: true, &)
  end

  def add_filter(name, chip: "#{name}: any")
    click_button "+ Add filter"
    within_menu { click_link name }

    expect(page).to have_button(chip)
  end

  # Capybara has no "focus this element" API, and the tooltip attaches its
  # focusin listener on connect, so focusing before that is silently dropped.
  def focus_overflow_marker
    expect(page).to have_css("[data-controller~='ruby-ui--tooltip']")

    page.execute_script(<<~JS)
      [...document.querySelectorAll("tbody [tabindex]")]
        .find((el) => el.textContent.trim().startsWith("+"))
        .focus();
    JS
  end

  def choose_tab(name, chip:)
    click_link name

    expect(page).to have_button(chip)
  end

  def within_tabs(&)
    within("nav[aria-label^='Views of']", &)
  end

  describe "the row" do
    it "shows the entity's tags" do
      expect(page).to have_css("td", text: "payments")
    end

    it "counts the tags that did not fit" do
      expect(page).to have_css("[tabindex]", text: "+1")
    end

    it "names them for assistive tech" do
      expect(page).to have_css("[tabindex][aria-label='One more tag']")
    end

    it "shows them on hover" do
      find("[tabindex]", text: "+1").hover

      expect(page).to have_css("body > [id^='tooltip']", text: "platform")
    end

    it "shows them on keyboard focus" do
      focus_overflow_marker

      expect(page).to have_css("body > [id^='tooltip']", text: "platform")
    end

    it "leaves a tag's tooltip to the overflow controller" do
      expect(page.evaluate_script(
               "[...document.querySelectorAll(\"tbody [title='payments']\")]" \
               ".every(el => 'overflowTitle' in el.dataset)"
             )).to be(true)
    end

    it "says so when there are none" do
      expect(page).to have_text("none")
    end

    it "shows the lifecycle" do
      expect(page).to have_text("Production")
    end
  end

  describe "on a narrow window" do
    let(:window) { Capybara.current_session.current_window }

    before do
      create(:component, title: "artist-engagement-platform-lookup",
                         tags: %w[payments go platform infra],
                         owner: create(:group, title: "Artist Engagement Platform"))
      window.resize_to(900, 900)
      visit components_path
    end

    after { window.resize_to(1400, 900) }

    def measure(script)
      page.evaluate_script(script)
    end

    def cut_values
      "[...document.querySelectorAll('tbody td *')]" \
        ".filter(el => el.textContent.trim() !== '' && " \
        "el.scrollWidth > el.clientWidth + 1)"
    end

    it "scrolls the listing instead of squeezing it" do
      expect(measure("(() => { const w = document.querySelector('table')" \
                     ".parentElement; return w.scrollWidth > w.clientWidth; })()"))
        .to be(true)
    end

    it "keeps every column readable" do
      widths = measure(
        "[...document.querySelectorAll('tbody tr:first-child td')]" \
        ".map(td => Math.round(td.getBoundingClientRect().width))"
      )

      expect(widths.min).to be >= 120
    end

    it "has a value too long for its column" do
      expect(measure("#{cut_values}.length")).to be_positive
    end

    it "clips it rather than painting over the next column" do
      expect(measure(
               "[...document.querySelectorAll('tbody td')]" \
               ".every(td => getComputedStyle(td).overflow === 'hidden')"
             )).to be(true)
    end

    it "ends a cut value with an ellipsis" do
      expect(measure(
               "#{cut_values}.every(el => " \
               "getComputedStyle(el).textOverflow === 'ellipsis')"
             )).to be(true)
    end

    it "does not put one on the cell as well" do
      expect(measure(
               "[...document.querySelectorAll('tbody td')]" \
               ".every(td => getComputedStyle(td).textOverflow === 'clip')"
             )).to be(true)
    end

    it "offers the whole value on hover" do
      expect(measure("#{cut_values}.every(el => el.title === el.textContent.trim())"))
        .to be(true)
    end

    it "leaves a value that fits without one" do
      expect(measure(
               "[...document.querySelectorAll('tbody td *')]" \
               ".filter(el => el.scrollWidth <= el.clientWidth + 1)" \
               ".every(el => !('overflowTitle' in el.dataset))"
             )).to be(true)
    end

    it "lays every value out inside its column" do
      expect(measure(<<~JS.squish)).to be <= 1
        Math.max(0, ...[...document.querySelectorAll('tbody td')].flatMap(td => {
          const edge = td.getBoundingClientRect().right;
          return [...td.querySelectorAll('*')].map(
            el => Math.round(el.getBoundingClientRect().right - edge));
        }))
      JS
    end

    it "keeps the tag overflow count visible" do
      expect(page).to have_css("tbody [tabindex]", text: "+2")
    end

    it "keeps the tag overflow count inside its column" do
      expect(measure(<<~JS.squish)).to be(true)
        (() => {
          const el = [...document.querySelectorAll('tbody [tabindex]')]
            .find(e => e.textContent.trim() === '+2');
          const box = el.getBoundingClientRect();
          return box.width > 0 &&
            box.right <= el.closest('td').getBoundingClientRect().right + 1;
        })()
      JS
    end
  end

  describe "the tabs" do
    it "counts what each one holds" do
      expect(find("a", text: /^All/).text)
        .to include(Junction::Component.count.to_s)
    end

    it "offers no unowned tab" do
      expect(page).to have_no_link("Unowned")
    end

    context "when a tab is chosen" do
      before { choose_tab "Production", chip: "Lifecycle: Production" }

      it "narrows the listing" do
        expect(page).to have_no_text(legacy.title)
      end

      it "keeps the entity that matches" do
        expect(page).to have_text(api.title)
      end

      it "marks the tab as the page being viewed" do
        within_tabs do
          expect(page).to have_css("a[aria-current='page']", text: "Production")
        end
      end

      it "puts the tab in the URL" do
        expect(page).to have_current_path(/tab=production/)
      end
    end
  end

  describe "the filter bar" do
    it "starts with no chips" do
      expect(page).to have_no_button(/Lifecycle:/)
    end

    it "offers the filters that are not on it" do
      click_button "+ Add filter"

      within_menu { expect(page).to have_link("Lifecycle") }
    end

    context "when a filter is added" do
      before do
        add_filter "Lifecycle"
      end

      it "puts it on the bar, unset" do
        expect(page).to have_button("Lifecycle: any")
      end

      it "remembers it in the URL" do
        expect(page).to have_current_path(/filters=lifecycle_eq/)
      end

      it "stops offering it" do
        click_button "+ Add filter"

        within_menu { expect(page).to have_no_link("Lifecycle") }
      end

      context "when it is given a value" do
        before do
          click_button "Lifecycle: any"
          within_menu { click_link "Deprecated" }
        end

        it "narrows the listing" do
          expect(page).to have_no_text(api.title)
        end

        it "names the value on the chip" do
          expect(page).to have_button("Lifecycle: Deprecated")
        end

        it "puts the filter in the URL" do
          expect(page).to have_current_path(/lifecycle_eq%5D=deprecated/)
        end

        it "offers a way to drop it" do
          click_link "Remove the Lifecycle filter"

          expect(page).to have_text(api.title)
        end
      end
    end
  end

  describe "the filter a tab stands for" do
    it "shows nothing on the tab that filters nothing" do
      expect(page).to have_no_button(/Owner:/)
    end

    context "when the production tab is chosen" do
      before { choose_tab "Production", chip: "Lifecycle: Production" }

      it "shows the tab as a chip" do
        expect(page).to have_button("Lifecycle: Production")
      end

      it "does not offer it in the add menu" do
        click_button "+ Add filter"

        within_menu { expect(page).to have_no_link("Lifecycle") }
      end

      it "leaves the tab when the chip is dropped" do
        click_link "Remove the Lifecycle filter"

        within_tabs do
          expect(page).to have_css("a[aria-current='page']", text: "All")
        end
      end

      it "keeps the entities when the chip is dropped" do
        click_link "Remove the Lifecycle filter"

        expect(page).to have_text(legacy.title)
      end

      it "leaves the tab when another value is chosen" do
        click_button "Lifecycle: Production"
        within_menu { click_link "Deprecated" }

        expect(page).to have_text(legacy.title)
      end
    end

    context "when the mine tab is chosen" do
      before { choose_tab "Mine", chip: "Owner: you and your groups" }

      it "names what the tab actually matches" do
        expect(page).to have_button("Owner: you and your groups")
      end
    end
  end
end
