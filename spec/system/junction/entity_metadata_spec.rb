# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Entity metadata", type: :system do
  let(:component) { create(:component) }

  before do
    sign_in_with_permissions(%w[
      junction.codes/components.all.read
      junction.codes/components.all.write
    ])
  end

  def tag_input
    find("#tags-field [data-tags-field-target='input']")
  end

  describe "tags", :js do
    before { visit edit_component_path(component) }

    context "when a tag is confirmed with Enter" do
      before { tag_input.send_keys("payments", :enter) }

      it "turns it into a chip" do
        expect(page).to have_css("#tags-field [data-tags-field-target='chip']",
                                 text: "payments")
      end

      it "does not submit the form" do
        expect(page).to have_current_path(edit_component_path(component))
      end
    end

    context "when a chip is created by the browser" do
      before { tag_input.send_keys("payments", :enter) }

      it "names the tag in the remove button's label" do
        expect(page).to have_button("Remove the payments tag")
      end
    end

    context "when a tag is left in the box and the form is saved" do
      before do
        fill_in "Tags", with: "payments"
        click_button "Save Changes"
      end

      it "commits it rather than dropping it" do
        expect(component.reload.tags).to eq(%w[payments])
      end
    end

    context "when the same tag is entered twice in different cases" do
      before do
        tag_input.send_keys("Payments", :enter)
        tag_input.send_keys("payments", :enter)
        click_button "Save Changes"
      end

      it "keeps one, lowercased" do
        expect(component.reload.tags).to eq(%w[payments])
      end
    end

    context "when a chip is removed" do
      let(:component) { create(:component, tags: %w[payments go]) }

      before do
        first("#tags-field [data-tags-field-target='chip'] button").click
        click_button "Save Changes"
      end

      it "drops that tag" do
        expect(component.reload.tags).to eq(%w[go])
      end
    end
  end

  describe "labels and links", :js do
    before { visit edit_component_path(component) }

    context "when typed into the blank rows" do
      before do
        within("#label-rows-field") do
          fill_in "Key", with: "tier"
          fill_in "Value", with: "gold"
        end

        within("#links-field") do
          fill_in "URL", with: "https://runbook.example.com"
          fill_in "Title", with: "Runbook"
        end

        click_button "Save Changes"
      end

      it "saves the label" do
        expect(component.reload.labels).to eq({ "tier" => "gold" })
      end

      it "saves the link" do
        expect(component.reload.links).to eq(
          [ { "url" => "https://runbook.example.com", "title" => "Runbook" } ]
        )
      end
    end

    context "when a link is saved without a url" do
      before do
        within("#links-field") { fill_in "Title", with: "Runbook" }
        click_button "Save Changes"
      end

      it "says what is wrong instead of looking like nothing happened" do
        expect(page).to have_css("#links_errors")
      end

      it "keeps the user on the form" do
        expect(page).to have_current_path(edit_component_path(component))
      end
    end

    context "when a link url has no scheme" do
      before do
        within("#links-field") do
          fill_in "URL", with: "runbook.example.com"
          fill_in "Title", with: "Runbook"
        end

        click_button "Save Changes"
      end

      it "rejects it rather than linking back into Junction" do
        expect(page).to have_css("#links_errors")
      end
    end

    context "when every label row is removed" do
      let(:component) { create(:component, labels: { "tier" => "gold" }) }

      before do
        within("#label-rows-field") do
          all("[data-repeatable-rows-target='row'] button").each(&:click)
        end

        click_button "Save Changes"
      end

      it "clears the labels" do
        expect(component.reload.labels).to eq({})
      end
    end
  end

  describe "the entity page" do
    let(:component) do
      create(:component, tags: %w[payments go], labels: { "tier" => "gold" },
                         links: [ { "url" => "https://runbook.example.com",
                                    "title" => "Runbook" } ])
    end

    before do
      driven_by(:rack_test)
      visit component_path(component)
    end

    it "shows the tags" do
      expect(page).to have_text("payments")
    end

    it "shows the labels as pairs" do
      expect(page).to have_text("= gold")
    end

    it "links out to the link" do
      expect(page).to have_link("Runbook", href: "https://runbook.example.com")
    end
  end
end
