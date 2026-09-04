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
      "annotations_keys", -> { annotation_keys_path }

    it_behaves_like "an annotations overview lazy frame",
      "annotations_entity_types", -> { annotation_entity_types_path }

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

    it "renders chart elements with panel-specific ids" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_key_path(slug)

      expect(response.body).to include("annotations-#{slug}-value-breakdown")
    end
  end

  describe "GET /annotations/entity-types/:entity_type" do
    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_type_path("groups") }, "junction.codes/annotations.all.read"

    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_type_path("domains") }, "junction.codes/annotations.all.read"

    it_behaves_like "an annotations overview action",
      :get, -> { annotation_entity_type_path("systems") }, "junction.codes/annotations.all.read"

    it "renders chart elements with panel-specific ids" do
      sign_in_user_with_permissions(%w[junction.codes/annotations.all.read])
      get annotation_entity_type_path("groups")

      expect(response.body).to include("annotations-groups-known-vs-other")
    end
  end

  describe "annotation form markup on entity edit pages" do
    let(:component) { create(:component) }

    before do
      sign_in_user_with_permissions(%w[junction.codes/components.all.write])
      get edit_component_path(component)
    end

    it "renders the add-row control" do
      expect(response.body).to include('data-action="click->annotations-form#add"')
    end

    it "renders the row template" do
      expect(response.body).to include('data-annotations-form-target="rowTemplate"')
    end

    it "renders other annotation fields with bare-bracket array notation" do
      expect(response.body).to include("other_annotations][][key]")
    end

    it "warns that annotations must not be used for secrets" do
      expect(response.body).to include("Never use them for secrets")
    end
  end
end
