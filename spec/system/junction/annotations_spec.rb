# frozen_string_literal: true

require "rails_helper"

SAMPLE_ANNOTATION = "junction.codes/team"

RSpec.describe "Junction::Annotations overview", :js, type: :system do
  before do
    create(:component, annotations: { "github.com/project-slug" => "org/repo" })
    create(:group, annotations: { SAMPLE_ANNOTATION => "admin" })
    sign_in_with_permissions(%w[junction.codes/annotations.all.read])
  end

  it "renders horizontal tabs on the index page" do
    visit annotations_path

    expect(page).to have_button("Annotations")
  end

  it "renders the entity types horizontal tab" do
    visit annotations_path

    expect(page).to have_button("Entity Types")
  end

  it "includes a lazy frame for annotation keys" do
    visit annotations_path

    expect(page).to have_css("turbo-frame#annotations_keys[src*='annotations/keys']")
  end

  it "loads annotation key tabs after the keys frame loads" do
    visit annotations_path

    expect(page).to have_css("turbo-frame#annotations_keys", wait: 10)
      .and have_text(SAMPLE_ANNOTATION, wait: 10)
  end

  it "loads entity types content when the tab is selected" do
    visit annotations_path
    click_button "Entity Types"

    expect(page).to have_css("turbo-frame#annotations_entity_types", wait: 10)
      .and have_text("Groups", wait: 10)
  end

  it "loads a key panel when a vertical tab is selected" do
    visit annotations_path
    slug = Junction::Annotations::Overview.new
      .slug_for(SAMPLE_ANNOTATION)
    click_button SAMPLE_ANNOTATION

    expect(page).to have_css("turbo-frame#annotation_key_#{slug}[complete]", wait: 10)
  end

  it "renders charts when a non-default vertical tab is selected" do
    visit annotations_path
    slug = Junction::Annotations::Overview.new
      .slug_for(SAMPLE_ANNOTATION)
    click_button SAMPLE_ANNOTATION

    expect(page).to have_css("turbo-frame#annotation_key_#{slug} canvas", wait: 10)
  end
end
