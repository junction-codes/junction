require 'rails_helper'

RSpec.describe "Apis", type: :request do
  subject!(:api) { create(:api) }

  let(:valid_attributes) {
    {
      name: "Test API",
      description: "An API for testing purposes",
      definition: "{}",
      lifecycle: "experimental",
      owner_id: create(:group).id,
      system_id: create(:system).id,
      type: "openapi"
    }
  }

  let(:invalid_attributes) {
    {
      lifecycle: "invalid_lifecycle",
      type: "invalid_type"
    }
  }

  context "when the user is not authenticated" do
    describe "GET /apis" do
      it_behaves_like 'an action that requires authentication', :get, -> { apis_path }
    end

    describe "GET /apis/:id" do
      it_behaves_like 'an action that requires authentication', :get, -> { api_path(api) }
    end

    describe "GET /apis/new" do
      it_behaves_like 'an action that requires authentication', :get, -> { new_api_path }
    end

    describe "GET /apis/:id/edit" do
      it_behaves_like 'an action that requires authentication', :get, -> { edit_api_path(api) }
    end

    describe "POST /apis" do
      it_behaves_like 'an action that requires authentication', :post, -> { apis_path }
    end

    describe "PATCH /apis/:id" do
      it_behaves_like 'an action that requires authentication', :patch, -> { api_path(api) }
    end

    describe "DELETE /apis/:id" do
      it_behaves_like 'an action that requires authentication', :delete, -> { api_path(api) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /apis" do
      it "returns http success" do
        get "/apis"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /apis/:id" do
      it "returns http success" do
        get "/apis/#{api.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /apis/new" do
      it "returns http success" do
        get "/apis/new"
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /apis/:id/edit" do
      it "returns http success" do
        get "/apis/#{api.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe "POST /apis" do
      context "with valid parameters" do
        it "creates a new api" do
          expect {
            post apis_url, params: { api: valid_attributes }
          }.to change(Api, :count).by(1)
        end

        it "redirects to the created api" do
          post apis_url, params: { api: valid_attributes }
          expect(response).to redirect_to(api_url(Api.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new api" do
          expect {
            post apis_url, params: { api: invalid_attributes }
          }.to change(Api, :count).by(0)
        end

        it "renders a response with 422 status" do
          post apis_url, params: { api: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /apis/:id" do
      context "with valid parameters" do
        let(:new_attributes) {
          {
            lifecycle: "production"
          }
        }

        it "updates the requested api" do
          patch api_url(api), params: { api: new_attributes }
          api.reload
          expect(api.lifecycle).to eq("production")
        end

        it "redirects to the api" do
          patch api_url(api), params: { api: new_attributes }
          api.reload
          expect(response).to redirect_to(api_url(api))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status" do
          patch api_url(api), params: { api: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /apis/:id" do
      it "destroys the requested api" do
        expect {
          delete api_url(api)
        }.to change(Api, :count).by(-1)
      end

      it "redirects to the apis list" do
        delete api_url(api)
        expect(response).to redirect_to(apis_url)
      end
    end
  end
end
