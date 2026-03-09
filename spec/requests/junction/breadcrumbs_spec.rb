# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Junction::Breadcrumbs concern", type: :request do
  fixtures "junction/components"

  subject(:component) { create(:component) }

  let(:components_write_permission) do
    %w[junction.codes/components.all.read junction.codes/components.all.write]
  end

  before { sign_in_user_with_permissions(components_write_permission) }

  describe "GET /components (index)" do
    before { get components_path }

    it "includes breadcrumb for the home page" do
      expect(response.body).to include(I18n.t("breadcrumbs.home"))
    end

    it "includes breadcrumb for the index page" do
      expect(response.body).to include(I18n.t("activerecord.models.component.other"))
    end
  end

  describe "GET /components/:id (show)" do
    before { get component_path(component) }

    it "includes breadcrumb for the home page" do
      expect(response.body).to include(I18n.t("breadcrumbs.home"))
    end

    it "includes breadcrumb for the index page" do
      expect(response.body).to include(I18n.t("activerecord.models.component.other"))
    end

    it "includes the component name in the breadcrumb" do
      expect(response.body).to include(component.name)
    end
  end

  describe "GET /components/new (new)" do
    it "includes breadcrumb for the home page" do
      get new_component_path

      expect(response.body).to include(I18n.t("breadcrumbs.home"))
    end

    context "when create fails validation and re-renders new" do
      before { post components_path, params: { component: { name: "" } } }

      it "includes breadcrumb for the new page" do
        expect(response.body).to include(
          I18n.t("breadcrumbs.new", model: I18n.t("activerecord.models.component.other"))
        )
      end
    end
  end

  describe "GET /components/:id/edit (edit)" do
    it "includes breadcrumb for the edit page" do
      get edit_component_path(component)

      expect(response.body).to include(I18n.t("breadcrumbs.edit"))
    end

    context "when update fails validation and re-renders edit" do
      before do
        patch component_path(component), params: { component: { name: "" } }
      end

      it "includes breadcrumb for the edit page" do
        expect(response.body).to include(I18n.t("breadcrumbs.edit"))
      end

      it "includes the entity label in the breadcrumb" do
        expect(response.body).to include(component.name)
      end
    end
  end
end
