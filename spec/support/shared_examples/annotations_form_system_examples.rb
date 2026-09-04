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
    if known_key
      allow(Junction::PluginRegistry).to receive(:annotations_for).and_call_original
      allow(Junction::PluginRegistry).to receive(:annotations_for)
        .with(entity.class)
        .and_return({ known_key => { key: known_key, title: known_key, placeholder: nil } })
    end

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

    describe "after saving a known annotation" do
      before do
        fill_in known_key, with: "known-value"
        click_button "Save Changes"
      end

      it "persists the annotation" do
        expect(entity.reload[:annotations][known_key]).to eq("known-value")
      end
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
