require 'rails_helper'

RSpec.describe "Junction::Components", :js, type: :system do
  before do
    sign_in_with_permissions(
      %w[
        junction.codes/components.all.read
        junction.codes/components.all.write
      ]
    )
  end

  describe "new component rich select create flow" do
    it "sets aria-expanded on the type trigger when opened" do
      visit new_component_path
      select = open_rich_select("Type")

      expect(select).to have_css(
        "[data-ruby-ui--select-target='trigger'][aria-expanded='true']"
      )
    end

    it "shows type filter input when opened" do
      visit new_component_path
      select = open_rich_select("Type")

      expect(select).to have_css(
        "[data-ruby-ui--select-target='filterInput']",
        visible: :visible
      )
    end

    it "closes the menu from filter input when escape is pressed" do
      visit new_component_path
      select = open_rich_select("Type")

      select.find("[data-ruby-ui--select-target='filterInput']").send_keys(:escape)

      expect(select).to have_css(
        "[data-ruby-ui--select-target='trigger'][aria-expanded='false']"
      )
    end

    it "moves focus from filter input to options on arrow down" do
      visit new_component_path
      select = open_rich_select("Type")

      select.find("[data-ruby-ui--select-target='filterInput']").send_keys(:down)

      expect(select).to have_css("[data-ruby-ui--select-target='item']", focused: true)
    end

    it "shows known group for type options" do
      create(:component, component_type: "custom_widget")

      visit new_component_path
      select = open_rich_select("Type")

      expect(select).to have_text(/known types/i)
    end

    it "shows other group for type options" do
      create(:component, component_type: "custom_widget")

      visit new_component_path
      select = open_rich_select("Type")

      expect(select).to have_text(/other types/i)
    end

    it "keeps focus in the filter input when create is clicked with blank query" do
      visit new_component_path
      select = open_rich_select("Type")

      select.find("[data-kind='create-action']").click

      expect(select).to have_css("[data-ruby-ui--select-target='filterInput']", focused: true)
    end

    it "stores the entered value when creating a new type option" do
      visit new_component_path
      select = open_rich_select("Type")
      select.find("[data-ruby-ui--select-target='filterInput']").set("brand_new_type")

      select.find("[data-kind='create-action']").click

      expect(find_by_id('component_type', visible: :hidden).value).to eq("brand_new_type")
    end

    it "shows created option description after selecting a new type value" do
      visit new_component_path
      select = open_rich_select("Type")
      select.find("[data-ruby-ui--select-target='filterInput']").set("brand_new_type")

      select.find("[data-kind='create-action']").click

      expect(page).to have_text("This option will be created.")
    end
  end
end
