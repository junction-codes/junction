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
end
