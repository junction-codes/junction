# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Domains scoped parent access", type: :system do
  after(:each, :js) do
    Capybara.reset_sessions!
    driven_by(:rack_test)
  end

  def load_page_with_text(path, text)
    visit path
    expect(page).to have_text(text)
  end

  def sign_in_existing_user(user)
    visit new_session_path
    fill_in "Your email", with: user.email_address
    fill_in "Password", with: "Password1!"
    click_button "Submit"
  end

  def submit_domain_form
    click_button "Save Changes"
  end

  let(:user_group) { create(:group) }
  let!(:inaccessible_parent) do
    create(:domain, title: "Parent Area", name: "scoped-parent-area", owner: create(:group), parent: nil)
  end
  let!(:owned_child) do
    create(:domain, title: "Child Group", name: "scoped-child-group",
                   parent: inaccessible_parent, owner: user_group)
  end

  prepend_before { driven_by(:rack_test) }

  before do
    user = create(:user, password: "Password1!", password_confirmation: "Password1!")
    create(
      :group_membership,
      user:,
      group: create(
        :group,
        annotations: {
          Junction::CorePlugin::ANNOTATION_GROUP_ROLE => create(
            :role,
            permissions: %w[
              junction.codes/domains.owned.read
              junction.codes/domains.owned.write
            ]
          ).name
        }
      )
    )
    create(:group_membership, user:, group: user_group)
    sign_in_existing_user(user)
  end

  it "shows the parent title without a link on show" do
    visit domain_path(owned_child)

    expect(page).to have_text("Parent Area")
  end

  it "does not link to the parent on show" do
    load_page_with_text(domain_path(owned_child), "Child Group")

    expect(page).to have_no_link("Parent Area")
  end

  it "shows the parent title on index" do
    load_page_with_text(domains_path, "Child Group")

    expect(find("tr", text: "Child Group")).to have_text("Parent Area")
  end

  it "does not link to the inaccessible parent on index" do
    load_page_with_text(domains_path, "Child Group")

    expect(find("tr", text: "Child Group")).to have_no_link(
      "Parent Area", href: domain_path(inaccessible_parent)
    )
  end

  it "renders a hidden parent_id field on edit" do
    visit edit_domain_path(owned_child)

    expect(page).to have_field("domain[parent_id]", type: :hidden, with: inaccessible_parent.id)
  end

  it "preserves parent_id when updating other fields" do
    visit edit_domain_path(owned_child)
    fill_in "domain_description", with: "Owned child update"
    submit_domain_form

    expect(owned_child.reload.parent_id).to eq(inaccessible_parent.id)
  end
end
