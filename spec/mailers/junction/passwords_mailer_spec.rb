# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::PasswordsMailer, type: :mailer do
  describe "#reset" do
    subject(:mail) { described_class.reset(user) }

    let(:user) { create(:user, email: "reset@example.com") }

    it "is addressed to the user" do
      expect(mail.to).to eq([ "reset@example.com" ])
    end

    it "names the subject" do
      expect(mail.subject).to eq("Reset your password")
    end
  end
end
