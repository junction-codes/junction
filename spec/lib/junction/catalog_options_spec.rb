# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::CatalogOptions do
  describe ".known_for" do
    it "returns known options for a mapped field" do
      expect(described_class.known_for(:api_type)).to eq(described_class.apis)
    end
  end

  describe ".known_values_for" do
    it "returns known values for a mapped field" do
      expect(described_class.known_values_for(:lifecycle)).to \
        eq(described_class.lifecycles.keys)
    end
  end

  describe ".validate!" do
    it "returns true for valid options data" do
      expect(described_class.validate!).to be(true)
    end

    it "raises when a configured section includes a blank key" do
      allow(described_class).to receive(:options).and_return(
        {
          apis: { "" => { name: "Blank" } },
          kinds: {},
          resources: {},
          group_types: {},
          lifecycles: {}
        }.with_indifferent_access
      )

      expect { described_class.validate! }.to raise_error(ArgumentError)
    end
  end

  describe ".options" do
    it "normalizes option keys into each option hash" do
      api_option = described_class.options.fetch(:apis).first.last
      expect(api_option[:key]).to be_present
    end

    it "normalizes options without id fields" do
      option = described_class.options.fetch(:apis).first.last
      expect(option).not_to have_key(:id)
    end
  end
end
