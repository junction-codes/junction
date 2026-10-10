# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Annotations::Overview do
  subject(:overview) { described_class.new }

  before do
    create(:component, annotations: { "github.com/project-slug" => "org/repo" })
    create(:group, annotations: { SAMPLE_ANNOTATION => "admin" })
  end

  describe "#annotation_key_tabs" do
    it "includes the registered group role key" do
      labels = overview.annotation_key_tabs.map { |tab| tab[:label] }

      expect(labels).to include(SAMPLE_ANNOTATION)
    end

    it "includes arbitrary annotation keys" do
      labels = overview.annotation_key_tabs.map { |tab| tab[:label] }

      expect(labels).to include("github.com/project-slug")
    end
  end

  describe "#entity_type_tabs" do
    it "lists the annotated kinds in the order the rail lists them" do
      ids = overview.entity_type_tabs.map { |tab| tab[:id] }

      expect(ids).to eq(%w[domains systems components apis resources groups users])
    end

    it "carries each kind's own icon" do
      icons = overview.entity_type_tabs.map { |tab| tab[:icon] }

      expect(icons).to all(be_present)
    end
  end

  describe "#annotation_key_detail" do
    subject(:panel) do
      overview.annotation_key_detail(overview.slug_for(SAMPLE_ANNOTATION))
    end

    it_behaves_like "an annotations overview panel",
      %i[id label known title total_count values entity_types]

    context "with an arbitrary annotation key" do
      subject(:panel) do
        overview.annotation_key_detail(overview.slug_for("github.com/project-slug"))
      end

      it "reports the top value without JSON encoding" do
        expect(panel[:entity_types].first[:top_value]).to eq("org/repo")
      end

      it "lists the values in use without JSON encoding" do
        expect(panel[:values]).to eq([ { value: "org/repo", count: 1 } ])
      end
    end

    context "with many distinct values" do
      subject(:values) do
        overview.annotation_key_detail(overview.slug_for("region"))[:values]
      end

      before do
        12.times do |index|
          create(:component, annotations: { "region" => format("region-%02d", index) })
        end
      end

      it "lists them all" do
        expect(values.size).to eq(12)
      end
    end
  end

  describe "a key with more values than the pane lists" do
    subject(:panel) do
      overview.annotation_key_detail(overview.slug_for("build.sha"))
    end

    before do
      (described_class::VALUE_LIMIT + 5).times do |index|
        create(:component, annotations: { "build.sha" => "sha-#{index}" })
      end
    end

    it "lists no more than the limit" do
      expect(panel[:values].size).to eq(described_class::VALUE_LIMIT)
    end

    it "still counts them all" do
      expect(panel[:values_total]).to eq(described_class::VALUE_LIMIT + 5)
    end
  end

  describe "#entity_type_detail" do
    subject(:panel) { overview.entity_type_detail("components") }

    it_behaves_like "an annotations overview panel",
      %i[id label record_count total_count keys_in_use known known_total other
         other_total]

    it "counts every record of the kind, not only the annotated ones" do
      expect(panel[:record_count]).to be >= panel[:total_count]
    end

    it "sums the uses of keys nothing declares" do
      expect(panel[:other_total]).to eq(1)
    end
  end

  describe "#slug_for" do
    before do
      create(:component, annotations: { "team.name" => "platform" })
      create(:component, annotations: { "team/name" => "infra" })
    end

    it "generates a distinct slug for keys that differ only by separator" do
      expect(overview.slug_for("team.name")).not_to eq(overview.slug_for("team/name"))
    end

    it "round-trips each key through its slug" do
      keys = %w[team.name team/name].map { |key| overview.key_for_slug(overview.slug_for(key)) }

      expect(keys).to eq(%w[team.name team/name])
    end
  end
end
