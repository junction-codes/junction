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
end
