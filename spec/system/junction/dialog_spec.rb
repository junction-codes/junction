# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Dialog", :js, type: :system do
  let(:group) { create(:group) }
  let(:dialog) { "dialog[data-ruby-ui--dialog-target='dialog']" }

  before do
    sign_in_with_permissions(
      %w[junction.codes/dashboards.all.read junction.codes/groups.all.read
         junction.codes/groups.all.write junction.codes/groups.all.destroy
         junction.codes/users.all.read]
    )
    visit edit_group_path(group)
  end

  it "renders the content in a native dialog element" do
    expect(page).to have_css(dialog, visible: :all)
  end

  it "keeps the dialog closed until it is triggered" do
    expect(page).to have_no_css(dialog)
  end

  context "when the trigger is clicked" do
    before { click_button "Delete Group" }

    it "opens the dialog" do
      expect(page).to have_css("#{dialog}[open]")
    end

    it "locks scrolling on the body" do
      expect(page).to have_css("body.overflow-hidden")
    end

    it "closes on escape" do
      find("body").send_keys(:escape)

      expect(page).to have_no_css("#{dialog}[open]")
    end

    it "unlocks scrolling once closed" do
      find("body").send_keys(:escape)

      expect(page).to have_no_css("body.overflow-hidden")
    end

    it "closes when the cancel link is clicked" do
      within(dialog) { click_link "Cancel" }

      expect(page).to have_no_css("#{dialog}[open]")
    end

    it "closes when the backdrop is clicked" do
      click_at(*point_outside_dialog)

      expect(page).to have_no_css("#{dialog}[open]")
    end

    # Clicks on the dialog's own padding target the <dialog> element just like
    # backdrop clicks do, so they must be told apart by pointer position.
    it "stays open when its own padding is clicked" do
      click_at(*point_in_dialog_padding)

      expect(page).to have_css("#{dialog}[open]")
    end
  end

  # A point a few pixels inside the dialog's top-left corner: within the
  # element, inside its p-6 padding, and not over any child.
  def point_in_dialog_padding
    rect = dialog_rect
    [ rect["left"] + 6, rect["top"] + 6 ]
  end

  # A point in the top-left of the viewport, well clear of the centred dialog.
  def point_outside_dialog
    [ 5, 5 ]
  end

  def dialog_rect
    page.evaluate_script(<<~JS)
      (() => {
        const r = document.querySelector(
          "dialog[data-ruby-ui--dialog-target='dialog']"
        ).getBoundingClientRect();
        return { left: r.left, top: r.top };
      })()
    JS
  end

  def click_at(x, y)
    page.driver.browser.mouse.click(x: x.to_i, y: y.to_i)
  end
end
