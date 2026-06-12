# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Domains", type: :system do
  after(:each, :js) do
    Capybara.reset_sessions!
    driven_by(:rack_test)
  end

  let(:root_domain) { create(:domain, title: "Root Area", name: "root-area", parent: nil) }
  let(:parent_domain) { create(:domain, title: "Parent Area", name: "parent-area", parent: nil) }
  let(:child_domain) { create(:domain, title: "Child Group", name: "child-group", parent: parent_domain) }

  def sign_in_domain_admin
    sign_in_with_permissions(%w[
      junction.codes/domains.all.read
      junction.codes/domains.all.write
      junction.codes/domains.all.destroy
    ])
  end

  def sign_in_existing_user(user)
    visit new_session_path
    fill_in "Your email", with: user.email_address
    fill_in "Password", with: "Password1!"
    click_button "Submit"
  end

  def fill_required_domain_fields(title:, description: "A domain description",
                                 status: "active", domain_type: "product-area")
    fill_in "domain_title", with: title
    fill_in "domain_description", with: description
    fill_in "domain_status", with: status
    find(:xpath, "//input[@name='domain[type]']", visible: :all).set(domain_type)
  end

  def submit_domain_form
    click_button "Save Changes"
  end

  def open_reference_select(label_text)
    field = find("label", text: /^#{Regexp.escape(label_text)}/)
    input_id = field[:for]
    select = if input_id.present?
      find(
        :xpath,
        "//*[@id='#{input_id}']/ancestor::*[@data-controller='ruby-ui--select'][1]",
        visible: :all
      )
    else
      field.find(:xpath, "..").find("[data-controller='ruby-ui--select']", visible: :all)
    end

    select.find("[data-ruby-ui--select-target='trigger']").click
    select
  end

  def select_parent(domain)
    select = open_reference_select("Parent")
    select.find("[data-ruby-ui--select-target='content']", visible: :visible, wait: 5)
    select.find("[data-ruby-ui--select-target='item']", text: domain.title).click
  end

  def clear_parent
    select = open_reference_select("Parent")
    select.find("[data-ruby-ui--select-target='item']", text: "No Parent selected").click
  end

  def load_page_with_text(path, text)
    visit path
    expect(page).to have_text(text)
  end

  def destroy_domain(domain)
    page.driver.browser.delete domain_path(domain)
  end

  describe "root domain (no parent)" do
    prepend_before { driven_by(:rack_test) }

    before do
      sign_in_domain_admin
      root_domain
    end

    it "lists the root domain with an empty parent column" do
      load_page_with_text(domains_path, "Root Area")

      expect(find("tr", text: "Root Area")).to have_no_link("Parent Area")
    end

    it "does not show a parent line on show" do
      load_page_with_text(domain_path(root_domain), "Root Area")

      expect(page).to have_no_text("Part of the")
    end

    it "creates a root domain without a parent" do
      visit new_domain_path
      fill_required_domain_fields(title: "Fresh Root")
      submit_domain_form

      expect(Junction::Domain.find_by!(name: "fresh-root").parent_id).to be_nil
    end

    it "updates the description on edit" do
      visit edit_domain_path(root_domain)
      fill_in "domain_description", with: "Updated root description"
      submit_domain_form

      expect(root_domain.reload.description).to eq("Updated root description")
    end

    it "destroys the domain from the edit page" do
      visit edit_domain_path(root_domain)

      expect { destroy_domain(root_domain) }.to change(Junction::Domain, :count).by(-1)
    end
  end

  describe "child domain (full parent access)" do
    prepend_before { driven_by(:rack_test) }

    before do
      sign_in_domain_admin
      parent_domain
      child_domain
    end

    it "shows the parent title as a link on index" do
      visit domains_path

      expect(page).to have_link("Parent Area", href: domain_path(parent_domain))
    end

    it "shows the parent line with a link on show" do
      visit domain_path(child_domain)

      expect(page).to have_link("Parent Area", href: domain_path(parent_domain))
    end

    it "keeps parent_id unchanged when editing other fields" do
      visit edit_domain_path(child_domain)
      fill_in "domain_description", with: "Updated child description"
      submit_domain_form

      expect(child_domain.reload.parent_id).to eq(parent_domain.id)
    end
  end

  describe "child domain reference picker flows", :js do
    before do
      sign_in_domain_admin
      parent_domain
      child_domain
    end

    it "creates a child domain with a selected parent" do
      visit new_domain_path
      fill_required_domain_fields(title: "Nested Child", description: "Nested description")
      select_parent(parent_domain)
      submit_domain_form

      expect(page).to have_link("Parent Area", href: domain_path(parent_domain))
    end

    it "assigns a parent to a root domain" do
      root = create(:domain, title: "Orphan Root", name: "orphan-root", parent: nil)
      visit edit_domain_path(root)
      select_parent(parent_domain)
      submit_domain_form

      expect(root.reload.parent_id).to eq(parent_domain.id)
    end

    it "clears the parent on edit" do
      visit edit_domain_path(child_domain)
      clear_parent
      submit_domain_form

      expect(page).to have_no_text("Part of the")
    end

    it "changes the parent to another domain" do
      other_parent = create(:domain, title: "Other Parent", name: "other-parent", parent: nil)
      visit edit_domain_path(child_domain)
      select_parent(other_parent)
      submit_domain_form

      expect(child_domain.reload.parent_id).to eq(other_parent.id)
    end

    it "shows the parent namespace in the picker options" do
      create(:domain, title: "Cross NS Parent", name: "cross-ns-parent", namespace: "backstage")
      visit new_domain_path
      item = open_reference_select("Parent").find("[data-ruby-ui--select-target='item']", text: "Cross NS Parent")

      expect(item.text).to include("backstage")
    end
  end

  describe "parent domain (has children)" do
    prepend_before { driven_by(:rack_test) }

    before do
      sign_in_domain_admin
      parent_domain
      child_domain
    end

    it "shows a blank parent column for the parent row" do
      visit domains_path

      parent_row = all("tr").find { |row| row.text.include?("Parent Area") && row.text.exclude?("Child Group") }
      expect(parent_row.all("td").last.text.strip).to be_empty
    end

    it "shows the parent domain on show" do
      visit domain_path(parent_domain)

      expect(page).to have_text("Parent Area")
    end

    it "keeps children referencing the parent after editing parent metadata" do
      visit edit_domain_path(parent_domain)
      fill_in "domain_description", with: "Updated parent description"
      submit_domain_form

      expect(child_domain.reload.parent_id).to eq(parent_domain.id)
    end

    it "destroys the parent and its children" do
      expect { destroy_domain(parent_domain) }.to change(Junction::Domain, :count).by(-2)
    end

    it "does not assign the domain as its own parent" do
      visit edit_domain_path(parent_domain)
      find("input[name='domain[parent_id]']", visible: :all).set(parent_domain.id)
      submit_domain_form

      expect(parent_domain.reload.parent_id).to be_nil
    end

    it "rejects assigning a descendant as parent" do
      visit edit_domain_path(parent_domain)
      find("input[name='domain[parent_id]']", visible: :all).set(child_domain.id)
      submit_domain_form

      expect(parent_domain.reload.parent_id).to be_nil
    end
  end

  describe "parent access paths" do
    context "when the user can access the parent" do
      prepend_before { driven_by(:rack_test) }

      before do
        sign_in_domain_admin
        parent_domain
        child_domain
      end

      it "shows a parent link on show" do
        visit domain_path(child_domain)

        expect(page).to have_link("Parent Area", href: domain_path(parent_domain))
      end

      it "shows an interactive parent field on edit" do
        load_page_with_text(edit_domain_path(child_domain), "Child Group")

        expect(page).to have_no_field("domain[parent_id]", type: :hidden, with: parent_domain.id)
      end
    end
  end

  describe "permissions smoke" do
    prepend_before { driven_by(:rack_test) }

    it "allows read-only users to view domains without create actions" do
      create(:domain, title: "Visible Domain", name: "visible-domain")
      sign_in_with_permissions(%w[junction.codes/domains.all.read])
      load_page_with_text(domains_path, "Visible Domain")

      expect(page).to have_no_link("New Domain")
    end

    it "redirects unauthorized users away from the index" do
      user = create(:user, password: "Password1!", password_confirmation: "Password1!")
      sign_in_existing_user(user)

      expect { visit domains_path }.to raise_error(Capybara::InfiniteRedirectError)
    end
  end
end
