# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Sourced do
  subject(:component) { build(:component) }

  describe "#managed_externally?" do
    it "is false for an entity created in the app" do
      expect(component).not_to be_managed_externally
    end

    it "is true for an entity a location declares" do
      component.managed_by = described_class::LOCATION
      expect(component).to be_managed_externally
    end

    it "is true for an entity a plugin owns" do
      component.managed_by = described_class::PLUGIN
      expect(component).to be_managed_externally
    end
  end

  describe "managed_by" do
    it "defaults to the user" do
      expect(component.managed_by).to eq(described_class::USER)
    end

    it "rejects a value outside the known set" do
      component.managed_by = "somewhere-else"
      expect(component).not_to be_valid
    end
  end

  describe ".user_managed" do
    let(:group) { create(:group) }

    before do
      create(:component, name: "mine", owner: group)
      create(:component, name: "theirs", owner: group,
             managed_by: described_class::LOCATION)
    end

    it "includes entities a user manages" do
      expect(Junction::Component.user_managed.pluck(:name)).to include("mine")
    end

    it "excludes entities a location manages" do
      expect(Junction::Component.user_managed.pluck(:name)).not_to include("theirs")
    end
  end
end
