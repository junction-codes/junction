# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Annotations forms", type: :system do
  describe "known and other annotation fields" do
    before { driven_by(:rack_test) }

    it_behaves_like "an annotations form",
      :group,
      ->(group) { edit_group_path(group) },
      %w[junction.codes/groups.all.read junction.codes/groups.all.write],
      known_key: Junction::CorePlugin::ANNOTATION_GROUP_ROLE

    it_behaves_like "an annotations form",
      :component,
      ->(component) { edit_component_path(component) },
      %w[junction.codes/components.all.read junction.codes/components.all.write]
  end

  describe "add row" do
    let(:component) { create(:component) }

    before do
      driven_by(:rack_test)
      sign_in_with_permissions(%w[
        junction.codes/components.all.read
        junction.codes/components.all.write
      ])
    end

    it "renders add-row controls for other annotations" do
      visit edit_component_path(component)

      expect(page).to have_button("Add annotation")
    end
  end

  describe "with multiple other annotations", :js do
    let(:component) { create(:component, annotations: { "existing/key" => "existing-value" }) }

    before do
      sign_in_with_permissions(%w[
        junction.codes/components.all.read
        junction.codes/components.all.write
      ])
      visit edit_component_path(component)

      click_button "Add annotation"
      within all("[data-annotations-form-target='list'] .other-annotation-row").last do
        fill_in "Name", with: "custom/example"
        fill_in "Value", with: "custom-value"
      end
      click_button "Save Changes"
    end

    it "persists both the existing row and a row added via the add button" do
      expect(component.reload[:annotations]).to eq(
        "existing/key" => "existing-value",
        "custom/example" => "custom-value"
      )
    end
  end

  describe "removing a row", :js do
    let(:component) do
      create(:component, annotations: { "existing/key" => "existing-value", "region" => "us-east" })
    end

    before do
      sign_in_with_permissions(%w[
        junction.codes/components.all.read
        junction.codes/components.all.write
      ])
      visit edit_component_path(component)

      # jsonb does not preserve key insertion order, so locate the row by its
      # rendered value instead of assuming a fixed position.
      row = all("[data-annotations-form-target='list'] .other-annotation-row")
        .find { |candidate| candidate.find_field("Name").value == "region" }
      within(row) { click_button "Remove annotation" }
      click_button "Save Changes"
    end

    it "drops the removed annotation on save" do
      expect(component.reload[:annotations]).to eq("existing/key" => "existing-value")
    end
  end
end
