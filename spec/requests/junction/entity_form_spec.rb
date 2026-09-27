# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The entity form", type: :request do
  before do
    user = create_user_with_permissions(%w[junction.codes/components.all.read
                                           junction.codes/components.all.write])
    sign_in(user:, password: "Password1!")
  end

  describe "creating" do
    before { get new_component_path }

    it "offers entering the details by hand" do
      expect(response.body).to include("Enter it manually")
    end

    it "marks the sources that do not exist yet" do
      waiting = response.parsed_body.css("[aria-disabled='true']").map(&:text)

      expect(waiting.join(" ")).to include("Scan a repository").and include("Import YAML")
    end

    it "shows the metadata fields without a tab to open" do
      expect(response.parsed_body.css("[data-ruby-ui--tabs-target='trigger']")).to be_empty
    end

    it "asks for tags" do
      expect(response.parsed_body.at_css("#tags-field")).to be_present
    end
  end

  describe "editing" do
    let(:component) do
      create(:component, tags: %w[api tier-1], labels: { "team" => "atlas" })
    end

    before { get edit_component_path(component) }

    def trigger(value)
      response.parsed_body.at_css("[data-ruby-ui--tabs-target='trigger'][data-value='#{value}']")
    end

    it "puts the metadata behind tabs" do
      values = response.parsed_body.css("[data-ruby-ui--tabs-target='trigger']")
                                   .map { |trigger| trigger["data-value"] }

      expect(values).to eq(%w[tags labels links annotations])
    end

    it "opens the first pane" do
      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-active-value"])
        .to eq("tags")
    end

    it "says how much each pane holds" do
      counts = %w[tags labels links annotations].map { |name| trigger(name).text.squish }

      expect(counts).to eq([ "Tags 2", "Labels 1", "Links 0", "Annotations 0" ])
    end
  end

  describe "a save rejected in more than one pane" do
    let(:component) { create(:component) }

    def trigger(value)
      response.parsed_body.at_css("[data-ruby-ui--tabs-target='trigger'][data-value='#{value}']")
    end

    before do
      patch component_path(component), params: { component: {
        title: component.title, name: component.name,
        namespace: component.namespace, description: component.description,
        type: component.type, lifecycle: component.lifecycle,
        owner_id: component.owner_id,
        tags: [ "one", "two", "three", "bad!tag" ],
        links: { "0" => { "url" => "", "title" => "Runbook" } }
      } }
    end

    it "marks the pane it opens" do
      expect(trigger("tags").text).to include("1 problem")
    end

    it "marks the pane it does not open" do
      expect(trigger("links").text).to include("1 problem")
    end

    it "leaves a pane with nothing wrong unmarked" do
      expect(trigger("labels").text).not_to include("problem")
    end

    it "shows the complaint in place of the count" do
      expect(trigger("tags").text).not_to include("4")
    end

    it "opens the first pane holding a complaint" do
      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-active-value"])
        .to eq("tags")
    end
  end

  describe "a save that was rejected" do
    let(:component) { create(:component) }

    before do
      patch component_path(component), params: {
        component: { links: { "0" => { "url" => "", "title" => "Runbook" } } }
      }
    end

    it "opens the pane holding the complaint" do
      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-active-value"])
        .to eq("links")
    end
  end
end
