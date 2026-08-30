require 'rails_helper'

RSpec.describe "/systems", type: :request do
  fixtures "junction/domains"

  subject!(:system) { create(:system) }

  let(:valid_attributes) {
    {
      description: "A description for the test system",
      domain_id: junction_domains(:one).id,
      title: "Test System",
      type: "service",
      image_url: "https://example.com/image.png",
      owner_id: junction_groups(:one).id
    }
  }

  let(:invalid_attributes) {
    {
      domain_id: nil,
      image_url: "invalid_url"
    }
  }

  context "when the user is not authenticated" do
    describe "GET /index" do
      it_behaves_like "an action that requires authentication", :get, -> { systems_path }
    end

    describe "GET /show" do
      it_behaves_like "an action that requires authentication", :get, -> { system_path(system) }
    end

    describe "GET /new" do
      it_behaves_like "an action that requires authentication", :get, -> { new_system_path }
    end

    describe "GET /edit" do
      it_behaves_like "an action that requires authentication", :get, -> { edit_system_path(system) }
    end

    describe "POST /create" do
      it_behaves_like "an action that requires authentication", :post, -> { systems_path }
    end

    describe "PATCH /update" do
      it_behaves_like "an action that requires authentication", :patch, -> { system_path(system) }
    end

    describe "DELETE /destroy" do
      it_behaves_like "an action that requires authentication", :delete, -> { system_path(system) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /index" do
      it_behaves_like "an action that requires permission",
        :get, -> { systems_path }, %w[junction.codes/systems.all.read]

      it_behaves_like "a paginated index",
        -> { systems_url }, Junction::System, :system

      it "renders a successful response" do
        get systems_url
        expect(response).to be_successful
      end

      context "when listing systems with types" do
        before do
          create(:system, title: "Known Type System", system_type: "feature-set")
          create(:system, title: "Unknown Type System", system_type: "custom_system_type")
        end

        it "displays the catalog name for a known system type" do
          get systems_url

          expect(response.body).to include("Feature Set")
        end

        it "displays a humanized label for an unknown system type" do
          get systems_url

          expect(response.body).to include("Custom system type")
        end
      end
    end

    describe "GET /show" do
      it_behaves_like "an action that requires permission",
        :get, -> { system_path(system) }, %w[junction.codes/systems.all.read]

      it "renders a successful response" do
        get system_path(system)
        expect(response).to be_successful
      end

      context "when the system has a known type" do
        let!(:typed_system) { create(:system, system_type: "feature-set") }

        it "displays the catalog name for the system type" do
          get system_path(typed_system)

          expect(response.body).to include("Feature Set")
        end
      end

      context "when the system has an unknown type" do
        let!(:typed_system) { create(:system, system_type: "custom_system_type") }

        it "displays a humanized label for the system type" do
          get system_path(typed_system)

          expect(response.body).to include("Custom system type")
        end
      end
    end

    describe "GET /apis" do
      it_behaves_like "an action that requires permission",
        :get, -> { system_apis_path(system) }, %w[junction.codes/systems.all.read]

      it_behaves_like "a paginated index",
        -> { system_apis_path(system) },
        -> { system.apis.count },
        :api,
        -> { { system: } }

      it "renders a successful response" do
        get system_apis_path(system)
        expect(response).to be_successful
      end
    end

    describe "GET /components" do
      it_behaves_like "an action that requires permission",
        :get, -> { system_components_path(system) }, %w[junction.codes/systems.all.read]

      it_behaves_like "a paginated index",
        -> { system_components_path(system) },
        -> { system.components.count },
        :component,
        -> { { system: } }

      it "renders a successful response" do
        get system_components_path(system)
        expect(response).to be_successful
      end
    end

    describe "GET /resources" do
      it_behaves_like "an action that requires permission",
        :get, -> { system_resources_path(system) }, %w[junction.codes/systems.all.read]

      it_behaves_like "a paginated index",
        -> { system_resources_path(system) },
        -> { system.resources.count },
        :resource,
        -> { { system: } }

      it "renders a successful response" do
        get system_resources_path(system)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it_behaves_like "an action that requires permission",
        :get, -> { new_system_path }, %w[junction.codes/systems.all.write]

      it_behaves_like "a request with a rich select field",
        request_proc: -> { new_system_url },
        known_label: "Known Types",
        other_label: "Other Types",
        search_placeholder: "Search Type",
        create_hint: "Start typing to create a new Type.",
        observed_value: "custom_system_type",
        setup_observed_value: -> { create(:system, system_type: "custom_system_type") }

      it "renders a successful response" do
        get new_system_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it_behaves_like "an action that requires permission",
        :get, -> { edit_system_path(system) }, %w[junction.codes/systems.all.write]

      it "renders a successful response" do
        get edit_system_path(system)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      it_behaves_like "an action that requires permission",
        :post, -> { systems_path },
        %w[junction.codes/systems.all.write junction.codes/systems.owned.write],
        -> { { system: valid_attributes.merge(owner_id: current_user.groups.first&.id) } }

      context "with valid parameters" do
        it "creates a new System" do
          expect {
            post systems_url, params: { system: valid_attributes }
          }.to change(Junction::System, :count).by(1)
        end

        it "redirects to the created system" do
          post systems_url, params: { system: valid_attributes }
          expect(response).to redirect_to(system_path(Junction::System.last))
        end

        it "assigns system type from the type param" do
          post systems_url, params: { system: valid_attributes.merge(type: "feature-set") }

          expect(Junction::System.last.system_type).to eq("feature-set")
        end
      end

      context "with invalid parameters" do
        it "does not create a new System" do
          expect {
            post systems_url, params: { system: invalid_attributes }
          }.not_to change(Junction::System, :count)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post systems_url, params: { system: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "displays the type validation error under the type field" do
          post systems_url, params: { system: valid_attributes.except(:type) }

          expect(response.body).to include('id="type_errors"')
        end
      end
    end

    describe "PATCH /update" do
      it_behaves_like "an action that requires permission",
        :patch, -> { system_path(system) },
        %w[junction.codes/systems.all.write junction.codes/systems.owned.write],
        { system: { title: "Updated System" } }

      context "with valid parameters" do
        let(:new_attributes) {
          {
            title: "Updated System"
          }
        }

        it "updates the requested system" do
          patch system_path(system), params: { system: new_attributes }
          system.reload
          expect(system.title).to eq("Updated System")
        end

        it "updates system type from the type param" do
          patch system_path(system), params: { system: { type: "feature-set" } }

          expect(system.reload.system_type).to eq("feature-set")
        end

        it "redirects to the system" do
          patch system_path(system), params: { system: new_attributes }
          system.reload
          expect(response).to redirect_to(system_path(system))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          patch system_path(system), params: { system: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /destroy" do
      it_behaves_like "an action that requires permission",
        :delete, -> { system_path(system) },
        %w[junction.codes/systems.all.destroy junction.codes/systems.owned.destroy]

      it "destroys the requested system" do
        expect {
          delete system_path(system)
        }.to change(Junction::System, :count).by(-1)
      end

      it "redirects to the systems list" do
        delete system_path(system)
        expect(response).to redirect_to(systems_url)
      end
    end
  end
end
