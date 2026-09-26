# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::MetadataOptions do
  subject(:options) { described_class.new(Junction::Component.where(id: ids)) }

  let(:ids) { [ first.id, second.id ] }
  let(:first) do
    create(:component, tags: %w[payments go], labels: { "team" => "atlas" })
  end
  let(:second) do
    create(:component, tags: %w[payments], labels: { "team" => "nova", "tier" => "gold" })
  end

  it "reads the tags in the scope, most used first" do
    expect(options.tags).to eq(%w[payments go])
  end

  it "reads only the scope's tags" do
    create(:component, tags: %w[elsewhere])

    expect(options.tags).not_to include("elsewhere")
  end

  it "reads the label keys in the scope" do
    expect(options.label_keys).to contain_exactly("team", "tier")
  end

  it "reads a key's values" do
    expect(options.label_values("team")).to contain_exactly("atlas", "nova")
  end

  it "has nothing to offer for a key nobody uses" do
    expect(options.label_values("nonsense")).to eq([])
  end

  # The queries join laterally rather than selecting `FROM` a named table, so
  # they follow the model wherever its table is and a host can't move it out
  # from under them.
  it "names no table of its own" do
    fragments = described_class.constants
                               .map { |name| described_class.const_get(name) }
                               .grep(String).join(" ")

    expect(fragments).not_to include(Junction::Entity.table_name)
  end

  # A key with a value per entity -- a build number, a commit -- must not
  # spend the whole menu's budget.
  describe "a key with many values" do
    subject(:options) { described_class.new(Junction::Component.where(id: ids)) }

    let(:ids) { crowded.map(&:id) + [ rare.id ] }
    let(:crowded) do
      Array.new(described_class::VALUES_PER_KEY + 5) do |i|
        create(:component, labels: { "build" => "sha#{i}" })
      end
    end
    let(:rare) { create(:component, labels: { "rare" => "yes" }) }

    it "still offers the other keys" do
      expect(options.label_keys).to include("rare")
    end

    it "offers that key its own share of values" do
      expect(options.label_values("build").size)
        .to eq(described_class::VALUES_PER_KEY)
    end

    it "offers the other key its values" do
      expect(options.label_values("rare")).to eq([ "yes" ])
    end
  end
end
