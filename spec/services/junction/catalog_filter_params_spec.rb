# frozen_string_literal: true

require "rails_helper"

RSpec.describe Junction::CatalogFilterParams do
  def params(**args)
    described_class.new(**args)
  end

  describe "#to_h" do
    it "leaves out filters with no value" do
      expect(params(query: { lifecycle_eq: "" }).to_h).to eq({})
    end

    it "carries the bar's membership" do
      expect(params(added: %w[type_eq owner_id_eq]).to_h[:filters])
        .to eq("type_eq,owner_id_eq")
    end

    it "carries a page size that is not the default" do
      expect(params(per_page: 50).to_h[:per_page]).to eq(50)
    end

    it "leaves out the default page size" do
      expect(params(per_page: Junction::Paginatable::DEFAULT_PER_PAGE).to_h)
        .not_to have_key(:per_page)
    end

    it "carries a tab" do
      expect(params(tab: "production").to_h[:tab]).to eq("production")
    end

    it "leaves out the default tab" do
      expect(params(tab: Junction::CatalogTabs::DEFAULT).to_h).not_to have_key(:tab)
    end

    it "carries the tag and label filters" do
      metadata = Junction::MetadataFilters.new(tags: %w[go], labels: { "team" => "atlas" })

      expect(params(metadata:).to_h)
        .to include(tags: %w[go], labels: { "team" => "atlas" })
    end
  end

  describe "#choose" do
    it "sets the value" do
      expect(params.choose("lifecycle_eq", "production").to_h[:q])
        .to eq(lifecycle_eq: "production")
    end

    it "keeps the other filters" do
      chosen = params(query: { type_eq: "service" }).choose("lifecycle_eq", "production")

      expect(chosen.to_h[:q]).to include(type_eq: "service")
    end

    it "takes a filter off the bar when it is cleared" do
      cleared = params(added: %w[lifecycle_eq]).choose("lifecycle_eq", nil)

      expect(cleared.to_h).not_to have_key(:filters)
    end

    it "leaves the tab when the filter it stands for is given a value" do
      chosen = params(tab: "production")
               .choose("lifecycle_eq", "deprecated", implied: "lifecycle_eq")

      expect(chosen.to_h).not_to have_key(:tab)
    end

    it "stays on the tab when another filter is chosen" do
      chosen = params(tab: "production")
               .choose("type_eq", "service", implied: "lifecycle_eq")

      expect(chosen.to_h[:tab]).to eq("production")
    end

    it "does not alter the set it came from" do
      original = params(query: { type_eq: "service" })
      original.choose("type_eq", "worker")

      expect(original.to_h[:q]).to eq(type_eq: "service")
    end
  end

  describe "#with_metadata" do
    it "replaces the tags" do
      original = params(metadata: Junction::MetadataFilters.new(tags: %w[go pci]))

      expect(original.with_metadata(tags: %w[go]).to_h[:tags]).to eq(%w[go])
    end

    it "keeps the labels it was not given" do
      metadata = Junction::MetadataFilters.new(tags: %w[go], labels: { "team" => "atlas" })

      expect(params(metadata:).with_metadata(tags: []).to_h[:labels])
        .to eq("team" => "atlas")
    end
  end

  describe "#cleared" do
    it "drops every filter" do
      full = params(query: { type_eq: "service" }, added: %w[owner_id_eq],
                    metadata: Junction::MetadataFilters.new(tags: %w[go]))

      expect(full.cleared.to_h).to eq({})
    end

    it "stays on the tab" do
      expect(params(tab: "production").cleared.to_h[:tab]).to eq("production")
    end
  end

  describe "#to_fields" do
    it "carries everything the search box does not own" do
      full = params(query: { title_cont: "pay", type_eq: "service" },
                    added: %w[type_eq], per_page: 50, tab: "production",
                    metadata: Junction::MetadataFilters.new(tags: %w[go]))

      expect(full.to_fields(except: :title_cont)).to contain_exactly(
        [ "tab", "production" ], [ "per_page", 50 ], [ "filters", "type_eq" ],
        [ "tags[]", "go" ], [ "q[type_eq]", "service" ]
      )
    end

    it "leaves the predicate the box owns to the box" do
      full = params(query: { title_cont: "pay" })

      expect(full.to_fields(except: :title_cont)).to be_empty
    end
  end
end
