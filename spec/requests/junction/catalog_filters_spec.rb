# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Catalog tag and label filters", type: :request do
  before do
    create(:component, title: "Alpha", tags: %w[payments go],
                       labels: { "team" => "atlas" })
    create(:component, title: "Beta", tags: %w[payments],
                       labels: { "team" => "nova" })
    create(:component, title: "Gamma", tags: [], labels: {})

    user = create_user_with_permissions(%w[junction.codes/components.all.read])
    sign_in(user:, password: "Password1!")
  end

  def search_form
    response.parsed_body.css("form").find { |form| form.at_css("input[name^='q[']") }
  end

  def titles
    response.parsed_body.css("tbody tr").map { |row| row.text[/(Alpha|Beta|Gamma)/] }.compact
  end

  describe "tags" do
    it "narrows to entities carrying the tag" do
      get components_path(tags: [ "payments" ])

      expect(titles).to contain_exactly("Alpha", "Beta")
    end

    it "narrows to entities carrying every tag given" do
      get components_path(tags: %w[payments go])

      expect(titles).to eq([ "Alpha" ])
    end

    it "renders a chip per tag" do
      get components_path(tags: %w[payments go])
      chips = response.parsed_body.css("span").map(&:text)

      expect(chips).to include("Tag: payments").and include("Tag: go")
    end

    it "keeps the other tags when one is dropped" do
      get components_path(tags: %w[payments go])
      remove = response.parsed_body.at_css("a[aria-label='Remove the go tag filter']")

      expect(remove["href"]).to include("tags%5B%5D=payments")
    end

    it "drops only the tag it names" do
      get components_path(tags: %w[payments go])
      remove = response.parsed_body.at_css("a[aria-label='Remove the go tag filter']")

      expect(remove["href"]).not_to include("go")
    end
  end

  describe "labels" do
    it "narrows to entities whose label holds the value" do
      get components_path(labels: { "team" => "atlas" })

      expect(titles).to eq([ "Alpha" ])
    end

    it "renders the pair on the chip" do
      get components_path(labels: { "team" => "atlas" })

      expect(response.body).to include("Label: team = atlas")
    end

    it "ignores a key with no value, which would mean any" do
      get components_path(labels: { "team" => "" })

      expect(titles).to contain_exactly("Alpha", "Beta", "Gamma")
    end
  end

  describe "a label that is not set" do
    it "narrows to entities carrying no such label" do
      get components_path(labels_unset: [ "team" ])

      expect(titles).to eq([ "Gamma" ])
    end

    it "says so on the chip rather than claiming a value" do
      get components_path(labels_unset: [ "team" ])

      expect(response.body).to include("Label: team — not set")
    end
  end

  describe "carrying filters" do
    it "keeps them on the search form" do
      get components_path(tags: [ "payments" ], labels: { "team" => "atlas" })

      expect(search_form.css("input[type='hidden']").map { |i| i["name"] })
        .to include("tags[]").and include("labels[team]")
    end

    it "offers to clear them" do
      get components_path(tags: [ "payments" ])
      clear = response.parsed_body.css("a").find { |a| a.text.strip == "Clear filters" }

      expect(clear["href"]).to eq(components_path)
    end
  end

  describe "links off the listing" do
    def hrefs(selector)
      response.parsed_body.css(selector).map { |node| node["href"] }.compact
    end

    before { get components_path(tags: [ "payments" ], labels: { "team" => "atlas" }) }

    it "keeps the filters when a column is sorted" do
      expect(hrefs("thead a")).to all(include("tags%5B%5D=payments"))
    end

    it "keeps the filters when the page size changes" do
      links = hrefs("a[href*='per_page']")

      expect(links).to all(include("labels%5Bteam%5D=atlas"))
    end

    it "keeps the filters when a tab is chosen" do
      expect(hrefs("main nav[aria-label] a")).to all(include("tags%5B%5D=payments"))
    end
  end

  describe "a malformed filter" do
    it "ignores labels given as a string" do
      get components_path(labels: "nonsense")

      expect(response).to have_http_status(:ok)
    end

    it "ignores labels given as a list" do
      get components_path(labels: [ "nonsense" ])

      expect(response).to have_http_status(:ok)
    end

    it "ignores tags given as pairs" do
      get components_path(tags: { "a" => "b" })

      expect(titles).to contain_exactly("Alpha", "Beta", "Gamma")
    end
  end

  describe "the values a menu offers" do
    before do
      create(:component, title: "Delta", tags: %w[solo])
      get components_path(tags: [ "payments" ])
    end

    it "leaves out a tag no remaining entity carries" do
      expect(response.body).not_to include(">solo<")
    end

    it "still offers a tag the remaining entities carry" do
      expect(response.body).to include(">go<")
    end
  end
end
