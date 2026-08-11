# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Users avatar", :js, type: :system do
  let(:fallback) { "[data-ruby-ui--avatar-target='fallback']" }
  let(:image) { "[data-ruby-ui--avatar-target='image']" }
  let(:user) { sign_in_with_permissions(%w[junction.codes/dashboards.all.read]) }

  context "when the user has no image" do
    before do
      user.update!(image_url: nil)
      visit root_path
    end

    it "shows the fallback" do
      expect(page).to have_css(fallback)
    end

    it "does not render an image" do
      expect(page).to have_no_css(image, visible: :all)
    end
  end

  context "when the user's image cannot be loaded" do
    before do
      user.update!(image_url: "https://example.invalid/missing.png")
      visit root_path
    end

    it "shows the fallback" do
      expect(page).to have_css(fallback)
    end

    it "still renders the image element" do
      expect(page).to have_css(image, visible: :all)
    end

    it "hides the image" do
      expect(page).to have_no_css(image, visible: :visible)
    end
  end

  context "when the user has an image" do
    before do
      user.update!(image_url: "https://example.invalid/avatar.png")
      visit root_path
    end

    # A lazy-loaded image that the controller hides is never fetched, so its
    # load event never fires and it stays hidden forever. Matched on src rather
    # than the target attribute so the assertion still bites if the target is
    # removed.
    it "does not lazy-load the image" do
      expect(page).to have_no_css("img[src$='avatar.png'][loading]", visible: :all)
    end

    it "wires the image to the avatar controller" do
      expect(page).to have_css(
        "#{image}[data-action*='ruby-ui--avatar#showFallback']",
        visible: :all
      )
    end
  end
end
