# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Annotations overview", :js, type: :system do
  let(:sample_name) { SAMPLE_ANNOTATION.split("/").last }
  let(:slug) { Junction::Annotations::Overview.new.slug_for(SAMPLE_ANNOTATION) }

  let(:permissions) { %w[junction.codes/annotations.all.read] }

  before do
    create(:component, annotations: { "github.com/project-slug" => "org/repo" })
    create(:group, annotations: { SAMPLE_ANNOTATION => "admin" })
    sign_in_with_permissions(permissions)

    visit annotations_path
  end

  it "loads the panes into the page" do
    expect(page).to have_css("turbo-frame#annotations_panes[src*='annotations/keys']")
  end

  it "lists the keys once the panes arrive" do
    expect(page).to have_text(sample_name, wait: 10)
  end

  it "groups a key under the namespace it belongs to" do
    expect(page).to have_text(SAMPLE_ANNOTATION.split("/").first.upcase, wait: 10)
  end

  it "opens a key when its row is clicked" do
    click_button sample_name

    expect(page).to have_css("turbo-frame#annotation_key_#{slug}[complete]", wait: 10)
  end

  it "says which values are in use" do
    click_button sample_name

    expect(page).to have_text("Values in use", wait: 10)
  end

  context "when listing by entity type" do
    before { click_link "By entity type" }

    it "lists the kinds that carry annotations" do
      expect(page).to have_text("Groups", wait: 10)
    end

    it "keeps both ways reachable" do
      expect(page).to have_link("By key", wait: 10)
    end
  end

  describe "the current item in each switcher" do
    def style_of(element, property)
      page.evaluate_script(
        "getComputedStyle(arguments[0]).#{property}", element
      )
    end

    let(:permissions) do
      %w[junction.codes/annotations.all.read junction.codes/plugins.all.read]
    end

    let(:subnav) { "nav[aria-label='Settings']" }

    it "sets the settings tab apart from the others" do
      current = find("#{subnav} a[aria-current='page']")
      other = first("#{subnav} a:not([aria-current])")

      expect(style_of(current, "color")).not_to eq(style_of(other, "color"))
    end

    it "underlines the settings tab" do
      current = find("#{subnav} a[aria-current='page']")

      expect(style_of(current, "borderBottomColor")).not_to eq("rgba(0, 0, 0, 0)")
    end

    it "sets the open pane apart in the switch" do
      current = find("a[aria-current='page']", text: "By key", wait: 10)
      other = find("a", text: "By entity type")

      expect(style_of(current, "color")).not_to eq(style_of(other, "color"))
    end
  end
end
