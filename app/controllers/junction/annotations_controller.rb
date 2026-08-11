# frozen_string_literal: true

module Junction
  # Controller for the annotations overview page.
  class AnnotationsController < ApplicationController
    before_action :set_breadcrumbs

    # GET /annotations
    def index
      authorize! :annotations
      render Views::Annotations::Index.new(breadcrumbs:)
    end

    # GET /annotations/keys
    def keys
      authorize! :annotations
      render Views::Annotations::Keys.new(
        annotation_key_tabs: overview.annotation_key_tabs,
        breadcrumbs:
      )
    end

    # GET /annotations/entity-types
    def entity_types
      authorize! :annotations
      render Views::Annotations::EntityTypes.new(
        entity_type_tabs: overview.entity_type_tabs,
        breadcrumbs:
      )
    end

    # GET /annotations/keys/:annotation_key
    def annotation_key
      authorize! :annotations
      panel = overview.annotation_key_detail(params.expect(:annotation_key))
      return head :not_found if panel.nil?

      render Views::Annotations::AnnotationKey.new(panel:)
    end

    # GET /annotations/entity-types/:entity_type
    def entity_type
      authorize! :annotations
      panel = overview.entity_type_detail(params.expect(:entity_type))
      return head :not_found if panel.nil?

      render Views::Annotations::EntityType.new(panel:)
    end

    private

    attr_reader :breadcrumbs

    def overview
      @overview ||= Junction::Annotations::Overview.new
    end

    def set_breadcrumbs
      @breadcrumbs ||= [
        { href: root_path, label: t("junction.breadcrumbs.home") },
        { href: annotations_path, label: t("junction.views.annotations.index.title") }
      ]
    end
  end
end
