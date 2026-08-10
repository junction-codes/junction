# frozen_string_literal: true

# Shared examples for annotation fields on entity edit forms.
#
# @param factory [Symbol] Factory for the annotated entity.
# @param edit_path [Proc] Proc returning the edit path for the entity.
# @param permissions [Array<String>] Write permissions for the entity.
# @param known_key [String, nil] Expected known annotation key label fragment.
RSpec.shared_examples "an annotations form" do |factory, edit_path, permissions,
  known_key: nil|
  let(:entity) { create(factory) }

  before do
    sign_in_with_permissions(permissions)
    visit instance_exec(entity, &edit_path)
  end

  it "renders the other annotations section" do
    expect(page).to have_text("Other annotations")
  end

  if known_key
    it "renders the known annotations section" do
      expect(page).to have_text("Known annotations")
    end

    it "renders the known annotation field" do
      expect(page).to have_text(known_key)
    end
  end

  describe "after saving a custom annotation" do
    before do
      within("[data-annotations-form-target='list']") do
        fill_in "Name", with: "custom/example"
        fill_in "Value", with: "custom-value"
      end
      click_button "Save Changes"
    end

    it "persists the annotation" do
      expect(entity.reload[:annotations]["custom/example"]).to eq("custom-value")
    end
  end
end
