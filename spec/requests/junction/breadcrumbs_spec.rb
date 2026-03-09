# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Breadcrumbs concern", type: :request do
  fixtures "junction/components"

  subject(:component) { create(:component) }

  let(:components_write_permission) do
    %w[junction.codes/components.all.read junction.codes/components.all.write]
  end

  before { sign_in_user_with_permissions(components_write_permission) }

  # Assert that the given string appears inside the breadcrumb nav tag.
  #
  # This helps us avoid false positives from the same text elsewhere on the
  # page.
  #
  # @param strings [Array<String>] The strings to check for in the breadcrumb
  #   nav tag.
  def expect_breadcrumb_to_include(*strings)
    expect(breadcrumb_nav).to be_present,
      "expected breadcrumb nav to be present in the response but found #{breadcrumb_nav.inspect}"

    strings.each do |s|
      expect(breadcrumb_nav.text).to include(s),
        "expected breadcrumb nav to include #{s.inspect} but found #{breadcrumb_nav.text}"
    end
  end

  # Assert that the breadcrumb nav contains a link with the given href.
  #
  # @param href [String] The href to check for in the breadcrumb nav tag.
  def expect_breadcrumb_to_link_to(href)
    expect(breadcrumb_nav).to be_present,
      "expected breadcrumb nav to be present in the response but found #{breadcrumb_nav.inspect}"

    links = breadcrumb_nav.css("a[href]")
    expect(links.any? { |a| a["href"] == href }).to be(true),
      "expected breadcrumb nav to contain a link to #{href.inspect}, but found: #{links.map { |a| a['href'] }.inspect}"
  end

  # Get the breadcrumb nav tag from the response body.
  #
  # @return [Nokogiri::XML::Element] The breadcrumb nav tag.
  def breadcrumb_nav
    Nokogiri::HTML(response.body).at_css('nav[aria-label="breadcrumb"]')
  end

  describe "GET /components (index)" do
    before { get components_path }

    it "includes breadcrumb for the home page" do
      expect_breadcrumb_to_include(I18n.t("breadcrumbs.home"))
    end

    it "includes breadcrumb for the index page" do
      expect_breadcrumb_to_include(I18n.t("activerecord.models.component.other"))
    end

    it "includes a link to the root path in the breadcrumb" do
      expect_breadcrumb_to_link_to(root_path)
    end

    it "does not link the current page" do
      expect(breadcrumb_nav.css("a[href]").map { |a| a["href"] }).not_to \
        include(components_path)
    end
  end

  describe "GET /components/:id (show)" do
    before { get component_path(component) }

    it "includes breadcrumb for the home page" do
      expect_breadcrumb_to_include(I18n.t("breadcrumbs.home"))
    end

    it "includes breadcrumb for the index page" do
      expect_breadcrumb_to_include(I18n.t("activerecord.models.component.other"))
    end

    it "includes the component name in the breadcrumb" do
      expect_breadcrumb_to_include(component.name)
    end

    it "includes a link to the components index in the breadcrumb" do
      expect_breadcrumb_to_link_to(components_path)
    end

    it "does not link the component name (current page)" do
      expect(breadcrumb_nav.css("a[href]").map { |a| a["href"] }).to \
        eq([ root_path, components_path ])
    end
  end

  describe "GET /components/new (new)" do
    before { get new_component_path }

    it "includes breadcrumb for the home page" do
      expect_breadcrumb_to_include(I18n.t("breadcrumbs.home"))
    end

    it "includes breadcrumb for the new page" do
      expect_breadcrumb_to_include(
        I18n.t("breadcrumbs.new", model: I18n.t("activerecord.models.component.other"))
      )
    end

    it "includes a link to the components index in the breadcrumb" do
      expect_breadcrumb_to_link_to(components_path)
    end

    it "does not link the current page" do
      expect(breadcrumb_nav.css("a[href]").map { |a| a["href"] }).not_to \
        include(new_component_path)
    end
  end

  describe "GET /components/:id/edit (edit)" do
    before { get edit_component_path(component) }

    it "includes breadcrumb for the edit page" do
      expect_breadcrumb_to_include(I18n.t("breadcrumbs.edit"))
    end

    it "includes the component name in the breadcrumb" do
      expect_breadcrumb_to_include(component.name)
    end

    it "includes a link to the component show page in the breadcrumb" do
      expect_breadcrumb_to_link_to(component_path(component))
    end

    it "does not link the current page" do
      expect(breadcrumb_nav.css("a[href]").map { |a| a["href"] }).not_to \
        include(edit_component_path(component))
    end
  end

  describe "POST /components" do
    context "when create fails validation and re-renders new" do
      before { post components_path, params: { component: { name: "" } } }

      it "includes breadcrumb for the new page" do
        expect_breadcrumb_to_include(
          I18n.t("breadcrumbs.new", model: I18n.t("activerecord.models.component.other"))
        )
      end
    end
  end

  describe "PATCH /components/:id" do
    context "when update fails validation and re-renders edit" do
      before do
        patch component_path(component), params: { component: { name: "" } }
      end

      it "includes breadcrumb for the edit page" do
        expect_breadcrumb_to_include(I18n.t("breadcrumbs.edit"))
      end

      it "includes the component name in the breadcrumb" do
        expect_breadcrumb_to_include(component.name)
      end
    end
  end
end
