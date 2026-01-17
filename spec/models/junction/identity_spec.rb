# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Identity, type: :model do
  subject(:identity) { build(:identity) }

  describe "validations" do
    it_behaves_like "validates presence of", :provider
    it_behaves_like "validates presence of", :uid
    it_behaves_like "validates uniqueness of", :uid, scope: :provider
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end
end
