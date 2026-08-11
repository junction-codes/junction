# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Tooltip", :js, type: :system do
  let(:trigger) { "[data-ruby-ui--tooltip-target='trigger']" }
  let(:mounted) { "body > [id^='tooltip']" }

  before do
    sign_in_with_permissions(%w[junction.codes/dashboards.all.read])
    visit root_path
  end

  it "renders the content inside a template" do
    expect(page).to have_css(
      "template[data-ruby-ui--tooltip-target='content']",
      visible: :all
    )
  end

  it "does not mount the tooltip until it is hovered" do
    expect(page).to have_no_css(mounted, visible: :all)
  end

  context "when the trigger is hovered" do
    before { first(trigger).hover }

    it "mounts the tooltip into the body" do
      expect(page).to have_css("#{mounted}[data-state='open']", visible: :all)
    end

    it "shows the tooltip text" do
      expect(page).to have_css(mounted, text: "Switch to")
    end

    it "describes the trigger for assistive tech" do
      expect(page).to have_css("#{trigger}[aria-describedby]", visible: :all)
    end

    it "marks the tooltip closed when the pointer leaves" do
      first("h1").hover

      expect(page).to have_css("#{mounted}[data-state='closed']", visible: :all)
    end
  end
end
