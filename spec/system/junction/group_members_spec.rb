# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::GroupMembers", :js, type: :system do
  let(:group) { create(:group) }

  before do
    create(:group_membership, group:)
    create(:user, title: "Grace Hopper")
    sign_in_with_permissions(
      %w[junction.codes/dashboards.all.read junction.codes/groups.all.read
         junction.codes/groups.all.write junction.codes/groups.all.destroy
         junction.codes/users.all.read]
    )
    visit group_path(group)

    within("turbo-frame#group_members") { click_button "Add Member" }
    fill_in "Search users", with: "Grace"
    within("turbo-frame#member-search-results") do
      find("li[role='option']", text: "Grace Hopper").click
    end
    within("dialog") { click_button "Add Member" }
  end

  it "shows the new member in the table without a manual reload" do
    expect(page).to have_css("turbo-frame#group_members", text: "Grace Hopper")
  end

  it "keeps the members table populated" do
    expect(page).to have_css("turbo-frame#group_members table")
  end
end
