require 'rails_helper'

RSpec.describe "/resources", type: :request do
  subject!(:resource) { create(:resource) }

  let(:valid_attributes) {
    {
      name: "Test Resource",
      description: "A resource for testing purposes",
      type: "database",
      system_id: create(:system).id,
      owner_id: junction_groups(:one).id,
      image_url: "https://example.com/image.png"
    }
  }

  let(:invalid_attributes) {
    {
      type: "invalid_type",
      image_url: "gopher://example.com/image.png",
      system_id: nil
    }
  }

  context "when the user is not authenticated" do
    describe "GET /resources" do
      it_behaves_like 'an action that requires authentication', :get, -> { resources_path }
    end

    describe "GET /resources/:id" do
      it_behaves_like 'an action that requires authentication', :get, -> { resource_path(resource.id) }
    end

    describe "GET /resources/new" do
      it_behaves_like 'an action that requires authentication', :get, -> { new_resource_path }
    end

    describe "GET /resources/:id/edit" do
      it_behaves_like 'an action that requires authentication', :get, -> { edit_resource_path(resource.id) }
    end

    describe "POST /resources" do
      it_behaves_like 'an action that requires authentication', :post, -> { resources_path }
    end

    describe "PATCH /resources/:id" do
      it_behaves_like 'an action that requires authentication', :patch, -> { resource_path(resource.id) }
    end

    describe "DELETE /resources/:id" do
      it_behaves_like 'an action that requires authentication', :delete, -> { resource_path(resource.id) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /resources" do
      it "returns http success" do
        get resources_url
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /resources/:id" do
      it "returns http success" do
        get resource_url(resource.id)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /resources/new" do
      it "returns http success" do
        get new_resource_url
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /resources/:id/edit" do
      it "returns http success" do
        get edit_resource_url(resource)
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /resources" do
      context "with valid parameters" do
        it "creates a new resource" do
          expect {
            post resources_url, params: { resource: valid_attributes }
          }.to change(Junction::Resource, :count).by(1)
        end

        it "redirects to the created resource" do
          post resources_url, params: { resource: valid_attributes }
          expect(response).to redirect_to(resource_url(Junction::Resource.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new resource" do
          expect {
            post resources_url, params: { resource: invalid_attributes }
          }.not_to change(Junction::Resource, :count)
        end

        it "renders a response with 422 status" do
          post resources_url, params: { resource: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /resources/:id" do
      context "with valid parameters" do
        let(:new_attributes) {
          {
            type: "bucket"
          }
        }

        it "updates the requested resource" do
          patch resource_url(resource), params: { resource: new_attributes }
          resource.reload
          expect(resource.type).to eq("bucket")
        end

        it "redirects to the resource" do
          patch resource_url(resource), params: { resource: new_attributes }
          resource.reload
          expect(response).to redirect_to(resource_url(resource))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status" do
          patch resource_url(resource), params: { resource: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /resources/:id" do
      it "returns http success" do
        delete resource_url(resource)
        expect(response).to have_http_status(:see_other)
      end

      it "destroys the requested resource" do
        expect {
          delete resource_url(resource)
        }.to change(Junction::Resource, :count).by(-1)
      end

      it "redirects to the resources list" do
        delete resource_url(resource)
        expect(response).to redirect_to(resources_url)
      end
    end
  end
end
