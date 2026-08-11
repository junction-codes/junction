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
  end
end
