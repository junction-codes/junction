# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The sign-in page", :js, type: :system do
  before { visit new_session_path }

  def password_field
    find("input[name='password']", visible: :all)
  end

  it "hides the password by default" do
    expect(password_field[:type]).to eq("password")
  end

  context "when the password is revealed" do
    before { click_button "Show password" }

    it "shows what was typed" do
      expect(password_field[:type]).to eq("text")
    end


    it "reports that it is on" do
      expect(find_button("Show password")[:"aria-pressed"]).to eq("true")
    end

    it "covers the password again when pressed a second time" do
      click_button "Show password"

      expect(password_field[:type]).to eq("password")
    end

    # A revealed field must not be submitted as plain text, or the browser
    # takes the password for ordinary input and offers it back as autofill.
    # The event is dispatched rather than the form submitted.
    it "is covered again when the form is submitted" do
      page.execute_script(<<~JS)
        document.querySelector("form")
                .dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))
      JS

      expect(password_field[:type]).to eq("password")
    end
  end

  context "when a sign-in is rejected" do
    let(:user) { create(:user, password: "Password1!", password_confirmation: "Password1!") }

    before do
      fill_in "Email", with: user.email
      fill_in "Password", with: "wrong-password"
      click_button "Sign in"
    end

    it "says the pair was wrong" do
      expect(page).to have_text("Try another email address or password.")
    end

    it "keeps the user on the form" do
      expect(page).to have_button("Sign in")
    end
  end

  context "when the theme is light" do
    before { find("[aria-label='Light']").click }

    it "keeps the backdrop dark" do
      expect(background_of("body")).to eq("rgb(15, 23, 42)")
    end

    it "lights the card" do
      expect(background_of(".bg-surface")).to eq("rgb(255, 255, 255)")
    end
  end

  context "when the theme is dark" do
    before { find("[aria-label='Dark']").click }

    it "darkens the card" do
      expect(background_of(".bg-surface")).to eq("rgb(17, 22, 33)")
    end
  end

  def background_of(selector)
    page.evaluate_script(
      "getComputedStyle(document.querySelector('#{selector}')).backgroundColor"
    )
  end

  it "has no accessibility violations" do
    expect(page).to be_axe_clean
  end
end
