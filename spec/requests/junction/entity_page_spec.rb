# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The entity page", type: :request do
  let(:group) { create(:group, title: "Team Atlas") }
  let(:domain) { create(:domain, title: "Commerce") }
  let(:system) { create(:system, title: "Payments", domain:) }
  let(:component) do
    create(:component, title: "Payments API", namespace: "acme",
                       name: "payments-api", owner: group, system:,
                       lifecycle: "production",
                       repository_url: "https://git.example.com/payments-api",
                       annotations: { "b.example/key" => "two",
                                      "a.example/key" => "one" })
  end
  let(:permissions) do
    %w[junction.codes/components.all.read junction.codes/components.all.write
       junction.codes/systems.all.read junction.codes/domains.all.read
       junction.codes/groups.all.read]
  end

  before do
    user = create_user_with_permissions(permissions)
    sign_in(user:, password: "Password1!")
  end

  def page_header
    response.parsed_body.at_css("main header")
  end

  def pane(value)
    response.parsed_body.at_css("[data-ruby-ui--tabs-target='content'][data-value='#{value}']")
  end

  def annotations_pane = pane("annotations")

  def overview_pane = pane("overview")

  def trigger(value)
    response.parsed_body.at_css("[data-ruby-ui--tabs-target='trigger'][data-value='#{value}']")
  end

  describe "the header" do
    before { get component_path(component) }

    it "names the entity by its reference" do
      expect(page_header.text).to include("component:acme/payments-api")
    end

    it "links to the owner" do
      expect(page_header.at_css("a[href='#{group_path(group)}']").text).to eq("Team Atlas")
    end

    it "links to the system" do
      expect(page_header.at_css("a[href='#{system_path(system)}']").text).to eq("Payments")
    end

    it "links to the system's domain" do
      expect(page_header.at_css("a[href='#{domain_path(domain)}']").text).to eq("Commerce")
    end

    it "opens the repository in a new tab" do
      link = page_header.at_css("a[href='https://git.example.com/payments-api']")

      expect(link["target"]).to eq("_blank")
    end

    # `type` is a button attribute; on a link it is meaningless.
    it "renders no link with a button type" do
      expect(response.parsed_body.css("a[type]")).to be_empty
    end

    it "offers to edit from the menu" do
      expect(page_header.at_css("a[href='#{edit_component_path(component)}']")).to be_present
    end
  end

  context "without permission to see the system" do
    let(:permissions) { %w[junction.codes/components.all.read] }

    before { get component_path(component) }

    it "still names the system" do
      expect(page_header.text).to include("Payments")
    end

    it "does not link to it" do
      expect(page_header.at_css("a[href='#{system_path(system)}']")).to be_nil
    end
  end

  describe "the ownership card" do
    def person
      @person ||= create(:user, title: "Grace Hopper", email: "grace@example.com")
    end

    let(:component) { create(:component, owner: person) }

    context "when the viewer may read the owner" do
      let(:permissions) do
        %w[junction.codes/components.all.read junction.codes/users.all.read]
      end

      it "shows the owner's email" do
        get component_path(component)

        expect(response.body).to include("grace@example.com")
      end
    end

    context "when the viewer may not read the owner" do
      let(:permissions) { %w[junction.codes/components.all.read] }

      it "still names the owner" do
        get component_path(component)

        expect(response.body).to include("Grace Hopper")
      end

      it "withholds their email" do
        get component_path(component)

        expect(response.body).not_to include("grace@example.com")
      end
    end
  end

  context "without permission to edit" do
    let(:permissions) { %w[junction.codes/components.all.read] }

    before { get component_path(component) }

    it "has no menu" do
      expect(page_header.at_css("[aria-label='More actions']")).to be_nil
    end

    it "offers no way to edit annotations" do
      expect(annotations_pane.at_css("a[href='#{edit_component_path(component)}']")).to be_nil
    end
  end

  describe "the tabs" do
    it "opens the overview" do
      get component_path(component)

      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-active-value"])
        .to eq("overview")
    end

    it "names the default tab, which is the one a clean URL opens" do
      get component_path(component)

      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-default-value"])
        .to eq("overview")
    end

    it "keeps naming the default when another tab is open" do
      get component_path(component, tab: "annotations")

      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-default-value"])
        .to eq("overview")
    end

    it "opens the tab named in the URL" do
      get component_path(component, tab: "annotations")

      expect(response.parsed_body.at_css("[data-controller='ruby-ui--tabs']")["data-ruby-ui--tabs-active-value"])
        .to eq("annotations")
    end

    it "counts dependencies in both directions" do
      create(:relation, source: component, target: create(:api))
      create(:relation, source: create(:component), target: component)
      get component_path(component)

      expect(trigger("dependencies").text).to include("2")
    end

    it "counts annotations" do
      get component_path(component)

      expect(trigger("annotations").text).to include("2")
    end

    it "offers to edit annotations from their tab" do
      get component_path(component)

      expect(annotations_pane.at_css("a[href='#{edit_component_path(component)}']")).to be_present
    end

    it "leaves annotations off the overview" do
      get component_path(component)

      expect(overview_pane.css("h2").map(&:text)).not_to include("Annotations")
    end

    it "lists annotations by key" do
      get component_path(component)
      expect(annotations_pane.css("dt").map(&:text)).to eq(%w[a.example/key b.example/key])
    end
  end

  describe "a system" do
    let(:permissions) { %w[junction.codes/systems.all.read junction.codes/domains.all.read] }

    before do
      create_list(:component, 2, system:)
      get system_path(system)
    end

    it "counts its components on their tab" do
      expect(trigger("components").text).to include("2")
    end

    it "names its domain" do
      expect(page_header.at_css("a[href='#{domain_path(domain)}']").text).to eq("Commerce")
    end
  end

  describe "a group" do
    let(:permissions) { %w[junction.codes/groups.all.read] }

    it "has no ownership card, since nobody owns a group" do
      get group_path(group)

      expect(response.parsed_body.css("h2").map(&:text)).not_to include("Ownership")
    end
  end

  describe "a user" do
    let(:permissions) { %w[junction.codes/users.all.read] }

    before do
      get user_path(create(:user, pronouns: "they/them", email: "sam@example.com"))
    end

    it "shows their pronouns in place of a description" do
      expect(page_header.text).to include("they/them")
    end

    it "offers their email address" do
      expect(page_header.at_css("a[href='mailto:sam@example.com']")).to be_present
    end

    it "has no dependencies tab, since people are not dependable" do
      expect(trigger("dependencies")).to be_nil
    end

    it "counts their groups" do
      expect(response.parsed_body.text).to include("Total Groups")
    end
  end

  describe "the overview's cards" do
    let(:permissions) do
      %w[junction.codes/components.all.read junction.codes/systems.all.read
         junction.codes/domains.all.read junction.codes/groups.all.read
         junction.codes/users.all.read]
    end

    # Headings and the plugin card, in the order they appear.
    def overview_order
      overview_pane.css("#plugin-card, h2, p").map do |node|
        node["id"] == "plugin-card" ? "plugin" : node.text.strip
      end
    end

    # Stands in for a plugin registering a card against one slot.
    def stub_plugin_card(slot)
      card = Class.new(Phlex::HTML) do
        def initialize(entity:)
          @entity = entity
        end

        def view_template
          section(id: "plugin-card") do
            render Junction::Components::KindChip.new(entity: @entity, size: :lg,
                                                      class: "mt-1")
          end
        end
      end

      allow(Junction::PluginRegistry).to receive(:components_for)
        .with(context: anything, slot:)
        .and_return([ { component: card } ])
    end

    before do
      allow(Junction::PluginRegistry).to receive(:components_for).and_call_original
      stub_plugin_card(:overview_cards)
    end

    it "renders a card registered against every kind on a system too" do
      get system_path(system)

      expect(overview_pane.at_css("#plugin-card")).to be_present
    end

    it "keeps the group's own slot alongside the shared one" do
      stub_plugin_card(:group_profile_cards)
      get group_path(group)

      expect(overview_pane.css("#plugin-card").size).to eq(2)
    end

    it "keeps the user's own slot alongside the shared one" do
      stub_plugin_card(:user_profile_cards)
      get user_path(create(:user))

      expect(overview_pane.css("#plugin-card").size).to eq(2)
    end

    it "merges a caller's classes into the chip rather than replacing them" do
      get component_path(component)
      chip = overview_pane.at_css("#plugin-card > *")

      expect(chip["class"]).to include("mt-1").and include("h-12")
    end

    it "puts plugin cards above the tags" do
      get component_path(component)

      expect(overview_order.index("plugin")).to be < overview_order.index("Tags & labels")
    end

    context "with a group" do
      let(:permissions) { %w[junction.codes/groups.all.read] }

      it "puts its counts above the tags" do
        get group_path(group)

        expect(overview_order.index("Total Systems")).to be < overview_order.index("Tags & labels")
      end
    end
  end
end
