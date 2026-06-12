require 'rails_helper'

RSpec.describe "/domains", type: :request do
  subject!(:domain) { create(:domain) }

  let(:valid_attributes) {
    {
      description: "A domain for testing purposes",
      domain_type: "product-area",
      title: "Test Domain",
      image_url: "https://example.com/image.png",
      status: "active"
    }
  }

  let(:invalid_attributes) {
    {
      image_url: "invalid_url",
      status: "invalid_status"
    }
  }

  context "when the user is not authenticated" do
    describe "GET /index" do
      it_behaves_like "an action that requires authentication", :get, -> { domains_path }
    end

    describe "GET /show" do
      it_behaves_like "an action that requires authentication", :get, -> { domain_path(domain) }
    end

    describe "GET /new" do
      it_behaves_like "an action that requires authentication", :get, -> { new_domain_path }
    end

    describe "GET /edit" do
      it_behaves_like "an action that requires authentication", :get, -> { edit_domain_path(domain) }
    end

    describe "POST /create" do
      it_behaves_like "an action that requires authentication", :post, -> { domains_path }
    end

    describe "PATCH /update" do
      it_behaves_like "an action that requires authentication", :patch, -> { domain_path(domain) }
    end

    describe "DELETE /destroy" do
      it_behaves_like "an action that requires authentication",
        :delete, -> { domain_path(domain) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /index" do
      it_behaves_like "an action that requires permission",
        :get, -> { domains_path }, %w[junction.codes/domains.all.read]

      it_behaves_like "a paginated index",
        -> { domains_url }, Junction::Domain, :domain

      it "renders a successful response" do
        get domains_url
        expect(response).to be_successful
      end

      context "when listing domains with types" do
        before do
          create(:domain, title: "Known Type Domain", domain_type: "product-group")
          create(:domain, title: "Unknown Type Domain", domain_type: "custom_domain_type")
        end

        it "displays the catalog name for a known domain type" do
          get domains_url

          expect(response.body).to include("Product Group")
        end

        it "displays a humanized label for an unknown domain type" do
          get domains_url

          expect(response.body).to include("Custom domain type")
        end
      end
    end

    describe "GET /show" do
      it_behaves_like "an action that requires permission",
        :get, -> { domain_path(domain) }, %w[junction.codes/domains.all.read]

      it "renders a successful response" do
        get domain_path(domain)
        expect(response).to be_successful
      end

      context "when the domain has a known type" do
        let!(:typed_domain) { create(:domain, domain_type: "product-group") }

        it "displays the catalog name for the domain type" do
          get domain_path(typed_domain)

          expect(response.body).to include("Product Group")
        end
      end

      context "when the domain has an unknown type" do
        let!(:typed_domain) { create(:domain, domain_type: "custom_domain_type") }

        it "displays a humanized label for the domain type" do
          get domain_path(typed_domain)

          expect(response.body).to include("Custom domain type")
        end
      end
    end

    describe "GET /systems" do
      it_behaves_like "an action that requires permission",
        :get, -> { domain_systems_path(domain) }, %w[junction.codes/domains.all.read]

      it_behaves_like "a paginated index",
        -> { domain_systems_path(domain) },
        -> { domain.systems.count },
        :system,
        -> { { domain: } }

      it "renders a successful response" do
        get domain_systems_path(domain)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it_behaves_like "an action that requires permission",
        :get, -> { new_domain_path }, %w[junction.codes/domains.all.write]
      it_behaves_like "a request with a rich select field",
        request_proc: -> { new_domain_url },
        known_label: "Known Types",
        other_label: "Other Types",
        search_placeholder: "Search Type",
        create_hint: "Start typing to create a new Type.",
        observed_value: "custom_domain_type",
        setup_observed_value: -> { create(:domain, domain_type: "custom_domain_type") }

      it "renders a successful response" do
        get new_domain_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it_behaves_like "an action that requires permission",
        :get, -> { edit_domain_path(domain) }, %w[junction.codes/domains.all.write]

      it "renders a successful response" do
        get edit_domain_path(domain)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      it_behaves_like "an action that requires permission",
        :post, -> { domains_path },
        %w[junction.codes/domains.all.write junction.codes/domains.owned.write],
        -> { { domain: valid_attributes.merge(owner_id: current_user.groups.first&.id) } }

      context "with valid parameters" do
        it "creates a new Domain" do
          expect {
            post domains_url, params: { domain: valid_attributes }
          }.to change(Junction::Domain, :count).by(1)
        end

        it "redirects to the created domain" do
          post domains_url, params: { domain: valid_attributes }
          expect(response).to redirect_to(domain_path(Junction::Domain.last))
        end

        it "assigns domain type from the type param" do
          post domains_url, params: { domain: valid_attributes.merge(type: "product-group") }

          expect(Junction::Domain.last.domain_type).to eq("product-group")
        end
      end

      context "with invalid parameters" do
        it "does not create a new Domain" do
          expect {
            post domains_url, params: { domain: invalid_attributes }
          }.not_to change(Junction::Domain, :count)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post domains_url, params: { domain: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "displays the type validation error under the type field" do
          post domains_url, params: { domain: valid_attributes.except(:domain_type) }

          expect(response.body).to include('id="type_errors"')
        end
      end
    end

    describe "PATCH /update" do
      it_behaves_like "an action that requires permission",
        :patch, -> { domain_path(domain) },
        %w[junction.codes/domains.all.write junction.codes/domains.owned.write],
        { domain: { status: "closed" } }

      context "with valid parameters" do
        let(:new_attributes) {
          {
            status: "closed"
          }
        }

        it "updates the requested domain" do
          patch domain_path(domain), params: { domain: new_attributes }
          domain.reload
          expect(domain.status).to eq("closed")
        end

        it "updates domain type from the type param" do
          patch domain_path(domain), params: { domain: { type: "product-group" } }

          expect(domain.reload.domain_type).to eq("product-group")
        end

        it "redirects to the domain" do
          patch domain_path(domain), params: { domain: new_attributes }
          domain.reload
          expect(response).to redirect_to(domain_path(domain))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          patch domain_path(domain), params: { domain: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE /destroy" do
      it_behaves_like "an action that requires permission",
        :delete, -> { domain_path(domain) },
        %w[junction.codes/domains.all.destroy junction.codes/domains.owned.destroy]

      it "destroys the requested domain" do
        expect {
          delete domain_path(domain)
        }.to change(Junction::Domain, :count).by(-1)
      end

      it "redirects to the domains list" do
        delete domain_path(domain)
        expect(response).to redirect_to(domains_url)
      end
    end

    describe "parent assignment" do
      let!(:parent_domain) { create(:domain, title: "Parent Area", name: "parent-area") }

      it "creates a domain with a valid parent_id" do
        post domains_url, params: {
          domain: valid_attributes.merge(parent_id: parent_domain.id)
        }

        expect(Junction::Domain.last.parent_id).to eq(parent_domain.id)
      end

      it "updates a domain with a valid parent_id" do
        patch domain_path(domain), params: { domain: { parent_id: parent_domain.id } }

        expect(domain.reload.parent_id).to eq(parent_domain.id)
      end

      it "creates a domain with a parent in a different namespace" do
        cross_ns_parent = create(:domain, namespace: "backstage", name: "backstage-parent")
        post domains_url, params: {
          domain: valid_attributes.merge(parent_id: cross_ns_parent.id, namespace: "default")
        }

        expect(Junction::Domain.last.parent_id).to eq(cross_ns_parent.id)
      end

      context "when the parent is outside the user's readable scope" do
        let(:user) do
          create_user_with_permissions(%w[
            junction.codes/domains.owned.read
            junction.codes/domains.owned.write
          ])
        end
        let!(:scoped_parent) { create(:domain, owner: create(:group)) }

        before { sign_in(user: user, password: "Password1!") }

        it "does not assign an inaccessible parent on create" do
          post domains_url, params: {
            domain: valid_attributes.merge(
              owner_id: user.groups.first.id,
              parent_id: scoped_parent.id
            )
          }

          expect(Junction::Domain.last.parent_id).to be_nil
        end

        it "does not change parent_id to an inaccessible parent on update" do
          owned_domain = create(:domain, owner: user.groups.first)

          patch domain_path(owned_domain), params: {
            domain: { parent_id: scoped_parent.id }
          }

          expect(owned_domain.reload.parent_id).to be_nil
        end
      end
    end
  end
end
