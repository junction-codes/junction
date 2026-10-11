# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The role permission editor", :js, type: :system do
  let(:role) { create(:role, title: "Service Owner") }

  before do
    role.role_permissions.create!(permission: "junction.codes/components.all.read")

    sign_in_with_permissions(%w[
      junction.codes/roles.all.read
      junction.codes/roles.all.write
    ])

    visit edit_role_path(namespace: role.namespace, name: role.name)
  end

  def box(permission)
    find("input[value='#{permission}']", visible: :all)
  end

  def diff_row(permission)
    find("[data-role-permissions-target='diff'] li", text: permission)
  end

  it "shows the contexts the role touches" do
    expect(page).to have_text("junction.codes/components")
  end

  it "keeps the rest out of the way" do
    expect(page).to have_no_text("junction.codes/annotations")
  end

  it "reveals them on request" do
    click_link "Show everything ↓"

    expect(page).to have_text("junction.codes/annotations")
  end

  it "narrows to what is typed" do
    fill_in "Filter by domain or context", with: "component"

    expect(page).to have_no_text("junction.codes/apis")
  end

  context "when a permission is added" do
    before { box("junction.codes/components.owned.write").click }

    it "lists it as a change" do
      expect(diff_row("junction.codes/components.owned.write")).to have_text("+")
    end

    it "allows the change to be saved" do
      expect(page).to have_button("Save changes", disabled: false)
    end
  end

  context "when a permission is taken away" do
    before { box("junction.codes/components.all.read").click }

    it "lists it as a change" do
      expect(diff_row("junction.codes/components.all.read")).to have_text("−")
    end
  end

  it "has nothing to save until something changes" do
    expect(page).to have_button("Save changes", disabled: true)
  end

  it "allows a change to the details to be saved" do
    fill_in "Role name", with: "Service Steward"

    expect(page).to have_button("Save changes", disabled: false)
  end

  context "when Enter is pressed in the filter" do
    before do
      box("junction.codes/components.owned.write").click
      find_field("Filter by domain or context").send_keys("component", :enter)
    end

    it "does not save the form" do
      expect(page).to have_button("Save changes", disabled: false)
    end

    it "narrows the grid" do
      expect(page).to have_no_text("junction.codes/apis")
    end
  end
end
