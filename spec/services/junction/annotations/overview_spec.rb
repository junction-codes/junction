# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::Annotations::Overview do
  subject(:overview) { described_class.new }

  before do
    create(:component, annotations: { "github.com/project-slug" => "org/repo" })
    create(:group, annotations: { Junction::CorePlugin::ANNOTATION_GROUP_ROLE => "admin" })
  end

  describe "#annotation_key_tabs" do
    it "includes the registered group role key" do
      labels = overview.annotation_key_tabs.map { |tab| tab[:label] }

      expect(labels).to include(Junction::CorePlugin::ANNOTATION_GROUP_ROLE)
    end

    it "includes arbitrary annotation keys" do
      labels = overview.annotation_key_tabs.map { |tab| tab[:label] }

      expect(labels).to include("github.com/project-slug")
    end
  end

  describe "#entity_type_tabs" do
    it "includes all annotated entity types" do
      ids = overview.entity_type_tabs.map { |tab| tab[:id] }

      expect(ids).to eq(%w[apis components groups resources users])
    end
  end

  describe "#annotation_key_detail" do
    subject(:panel) do
      overview.annotation_key_detail(overview.slug_for(Junction::CorePlugin::ANNOTATION_GROUP_ROLE))
    end

    it_behaves_like "an annotations overview panel",
      %i[id label known title total_count entity_types charts]

    context "with an arbitrary annotation key" do
      subject(:panel) do
        overview.annotation_key_detail(overview.slug_for("github.com/project-slug"))
      end

      it "reports the top value without JSON encoding" do
        expect(panel[:entity_types].first[:top_value]).to eq("org/repo")
      end

      it "keys the value breakdown chart without JSON encoding" do
        expect(panel.dig(:charts, :value_breakdown)).to eq({ "org/repo" => 1 })
      end
    end
  end

  describe "#entity_type_detail" do
    subject(:panel) { overview.entity_type_detail("components") }

    it_behaves_like "an annotations overview panel",
      %i[id label total_count known other charts]

    it "charts the most used annotation keys" do
      expect(panel.dig(:charts, :top_keys)).to eq({ "github.com/project-slug" => 1 })
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
