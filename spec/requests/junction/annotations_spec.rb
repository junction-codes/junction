# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::AnnotationsController", type: :request do
  before do
    create(:component, annotations: { "github.com/project-slug" => "org/repo" })
    create(:group, annotations: { SAMPLE_ANNOTATION => "admin" })
  end

  describe "GET /annotations" do
    it_behaves_like "an annotations overview action",
      :get, -> { annotations_path }, "junction.codes/annotations.all.read"

    it_behaves_like "an annotations overview lazy frame",
      "annotations_panes", -> { annotation_keys_path }

    it "offers the other way of listing from inside the pane" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_keys_path

      switch = response.parsed_body.at_css("a[href='#{annotation_entity_types_path}']")

      expect(switch["data-turbo-frame"]).to eq("annotations_panes")
    end

    it "warns that annotations must not be used for secrets" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotations_path

      expect(response.body).to include("Never use annotations for secrets")
    end
  end

  describe "GET /annotations/keys" do
    it_behaves_like "an annotations overview action",
      :get, -> { annotation_keys_path }, "junction.codes/annotations.all.read"
  end

  describe "GET /annotations/entity-types" do
    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_types_path }, "junction.codes/annotations.all.read"
  end

  describe "GET /annotations/keys/:annotation_key" do
    let(:slug) do
      Junction::Annotations::Overview.new.slug_for(SAMPLE_ANNOTATION)
    end

    it_behaves_like "an annotations overview action",
      :get, -> { annotation_key_path(slug) }, "junction.codes/annotations.all.read"

    it "lists the values in use" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_key_path(slug)

      expect(response.body).to include("Values in use")
    end

    it "says how much of each kind carries the key" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_key_path(slug)

      expect(response.body).to include("Coverage")
    end
  end

  describe "the settings sub-nav" do
    before do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotations_path
    end

    it "is named" do
      expect(response.parsed_body.at_css("nav[aria-label='Settings']")).to be_present
    end
  end

  describe "GET /annotations/keys with nothing to list" do
    before do
      overview = instance_double(Junction::Annotations::Overview,
                                 annotation_key_tabs: [])
      allow(Junction::Annotations::Overview).to receive(:new).and_return(overview)

      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_keys_path
    end

    it "says there is nothing to list" do
      expect(response.body).to include("No annotations are currently present")
    end

    it "still offers the other way of listing" do
      expect(response.parsed_body.at_css("a[href='#{annotation_entity_types_path}']"))
        .to be_present
    end
  end

  describe "GET /annotations/entity-types/:entity_type" do
    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_type_path("groups") }, "junction.codes/annotations.all.read"

    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_type_path("domains") }, "junction.codes/annotations.all.read"

    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_type_path("systems") }, "junction.codes/annotations.all.read"

    it "splits the kind's keys into declared and undeclared" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_entity_type_path("groups")

      expect(response.body).to include("Declared keys")
        .and include("In use, but not declared")
    end

    context "when nothing of the kind is annotated" do
      before do
        sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
        get annotation_entity_type_path("systems")
      end

      it "says so" do
        expect(response.body).to include("No systems carry an annotation yet")
      end

      it "does not draw the split bar" do
        expect(response.body).not_to include("of annotations use a declared key")
      end
    end

    it "says how much of the kind is annotated" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_entity_type_path("groups")

      expect(response.body).to match(/\d+ records/)
    end
  end

  describe "annotation form markup on entity edit pages" do
    let(:component) { create(:component) }

    before do
      sign_in_user_with_permissions(%w[junction.codes/components.all.write])
      get edit_component_path(component)
    end

    it "renders the add-row control" do
      expect(response.body).to include('data-action="click->repeatable-rows#add"')
    end

    it "renders the row template" do
      expect(response.body).to include('data-repeatable-rows-target="rowTemplate"')
    end

    it "renders other annotation fields with bare-bracket array notation" do
      expect(response.body).to include("other_annotations][][key]")
    end

    it "warns that annotations must not be used for secrets" do
      expect(response.body).to include("Never use them for secrets")
    end
  end
end
