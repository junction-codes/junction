# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/components", type: :request do
  subject!(:component) { create(:component) }

  fixtures(*ENTITY_FIXTURE_SETS)

  let(:valid_attributes) {
    {
      title: "Test Component",
      description: "A component for testing purposes",
      lifecycle: "experimental",
      type: "api",
      image_url: "https://example.com/image.png",
      owner_id: junction_groups(:group_one).id,
      repository_url: "https://example.com/example/component.git"
    }
  }

  let(:invalid_attributes) {
    {
      lifecycle: "invalid_lifecycle",
      type: "invalid_type",
      image_url: "gopher://example.com/image.png",
      repository_url: "ftp://example.com/example/component.git"
    }
  }

  context "when the user is not authenticated" do
    describe "GET /components" do
      it_behaves_like 'an action that requires authentication', :get, -> { components_path }
    end

    describe "GET /components/:id" do
      it_behaves_like 'an action that requires authentication', :get, -> { component_path(component) }
    end

    describe "GET /components/new" do
      it_behaves_like 'an action that requires authentication', :get, -> { new_component_path }
    end

    describe "GET /components/:id/edit" do
      it_behaves_like 'an action that requires authentication', :get, -> { edit_component_path(component) }
    end

    describe "POST /components" do
      it_behaves_like 'an action that requires authentication', :post, -> { components_path }
    end

    describe "PATCH /components/:id" do
      it_behaves_like 'an action that requires authentication', :patch, -> { component_path(component) }
    end

    describe "DELETE /components/:id" do
      it_behaves_like 'an action that requires authentication', :delete, -> { component_path(component) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /components" do
      it_behaves_like "an action that requires permission",
        :get, -> { components_path }, %w[junction.codes/components.all.read]

      it_behaves_like "a paginated index",
        -> { components_url }, Junction::Component, :component

      it "renders a successful response" do
        get components_url
        expect(response).to be_successful
      end
    end

    describe "GET /components/:id" do
      it_behaves_like "an action that requires permission",
        :get, -> { component_path(component) }, %w[junction.codes/components.all.read]

      it "renders a successful response" do
        get component_path(component)
        expect(response).to be_successful
      end
    end



    describe "GET /components/new" do
      it_behaves_like "an action that requires permission",
        :get, -> { new_component_path }, %w[junction.codes/components.all.write]
      it_behaves_like "a request with a rich select field",
        request_proc: -> { new_component_url },
        known_label: "Known Types",
        other_label: "Other Types",
        search_placeholder: "Search Type",
        create_hint: "Start typing to create a new Type.",
        observed_value: "custom_widget",
        setup_observed_value: -> { create(:component, type: "custom_widget") }
      it_behaves_like "a request with a rich select field",
        request_proc: -> { new_component_url },
        known_label: "Known Lifecycles",
        other_label: "Other Lifecycles",
        search_placeholder: "Search Lifecycle",
        create_hint: "Start typing to create a new Lifecycle.",
        observed_value: "legacy_preview",
        setup_observed_value: -> { create(:component, lifecycle: "legacy_preview") }

      it "renders a successful response" do
        get new_component_url
        expect(response).to be_successful
      end
    end

    describe "GET /components/:id/edit" do
      it_behaves_like "an action that requires permission",
        :get, -> { edit_component_path(component) }, %w[junction.codes/components.all.write]

      it "renders a successful response" do
        get edit_component_path(component)
        expect(response).to be_successful
      end
    end

    describe "POST /components" do
      it_behaves_like "an action that requires permission",
        :post, -> { components_path },
        %w[junction.codes/components.all.write junction.codes/components.owned.write],
        -> { { component: valid_attributes.merge(owner_id: current_user.groups.first&.id) } }

      context "with valid parameters" do
        it "creates a new component" do
          expect {
            post components_url, params: { component: valid_attributes }
          }.to change(Junction::Component, :count).by(1)
        end

        it "redirects to the created component" do
          post components_url, params: { component: valid_attributes }
          expect(response).to redirect_to(component_path(Junction::Component.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new component" do
          expect {
            post components_url, params: { component: invalid_attributes }
          }.not_to change(Junction::Component, :count)
        end

        it "renders a response with 422 status" do
          post components_url, params: { component: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "PATCH /components/:id" do
      it_behaves_like "an action that requires permission",
        :patch, -> { component_path(component) },
        %w[junction.codes/components.all.write junction.codes/components.owned.write],
        { component: { lifecycle: "production" } }

      context "with valid parameters" do
        let(:new_attributes) {
          {
            lifecycle: "production"
          }
        }

        it "updates the requested component" do
          patch component_path(component), params: { component: new_attributes }
          component.reload
          expect(component.lifecycle).to eq("production")
        end

        it "redirects to the component" do
          patch component_path(component), params: { component: new_attributes }
          component.reload
          expect(response).to redirect_to(component_path(component))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status" do
          patch component_path(component), params: { component: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "entity metadata" do
      let(:metadata) {
        {
          tags: [ "portal", "java", "" ],
          label_rows: { "0" => { key: "tier", value: "gold" }, "1" => { key: "", value: "" } },
          links: { "0" => { url: "https://runbook.example.com", title: "Runbook", icon: "book-open" } }
        }
      }

      it "stores tags, labels and links on create" do
        post components_url,
             params: { component: valid_attributes.merge(metadata) }
        created = Junction::Component.find_by(title: "Test Component")

        expect(created).to have_attributes(
          tags: %w[portal java],
          labels: { "tier" => "gold" },
          links: [ { "url" => "https://runbook.example.com", "title" => "Runbook",
                     "icon" => "book-open" } ]
        )
      end

      it "updates them" do
        patch component_path(component), params: { component: metadata }

        expect(component.reload).to have_attributes(
          tags: %w[portal java],
          labels: { "tier" => "gold" }
        )
      end

      it "clears them when the form comes back empty" do
        component.update!(tags: %w[portal], labels: { "tier" => "gold" },
                          links: [ { "url" => "https://example.com" } ])

        patch component_path(component),
              params: { component: { tags: [ "" ], label_rows: { "0" => { key: "", value: "" } },
                                     links: { "0" => { url: "", title: "", icon: "" } } } }

        expect(component.reload).to have_attributes(tags: [], labels: {}, links: [])
      end

      it "leaves them alone when the form does not carry them" do
        component.update!(tags: %w[portal], labels: { "tier" => "gold" })

        patch component_path(component), params: { component: { lifecycle: "production" } }

        expect(component.reload).to have_attributes(tags: %w[portal],
                                                    labels: { "tier" => "gold" })
      end

      it "ignores a tag that is not well formed" do
        patch component_path(component), params: { component: { tags: [ "not a tag" ] } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "the updated column" do
      it "carries a machine-readable timestamp" do
        component

        get components_url

        expect(response.body).to include(%(datetime="#{component.updated_at.iso8601}"))
      end

      it "says how long ago in words" do
        component

        get components_url

        expect(response.body).to include("less than a minute ago")
      end
    end

    describe "the listing tabs" do
      let(:owned) { create(:group) }

      before do
        user = create_user_with_permissions([ "junction.codes/components.all.read" ])
        create(:group_membership, user:, group: owned)
        create(:component, title: "ours", owner: owned, lifecycle: "production")
        create(:component, title: "theirs", lifecycle: "experimental")
        sign_in(user:, password: "Password1!")
      end

      it "shows everything by default" do
        get components_url

        expect(response.body).to include("ours").and include("theirs")
      end

      it "narrows to what the user's groups own" do
        get components_url(tab: "mine")

        expect(response.body).to include("ours")
      end

      it "leaves out what they do not own" do
        get components_url(tab: "mine")

        expect(response.body).not_to include("theirs")
      end

      it "narrows to production" do
        get components_url(tab: "production")

        expect(response.body).not_to include("theirs")
      end

      it "falls back to everything for an unknown tab" do
        get components_url(tab: "nonsense")

        expect(response.body).to include("ours").and include("theirs")
      end

      it "keeps the filters when a tab is chosen" do
        get components_url(tab: "mine", q: { title_or_description_cont: "ours" })

        expect(response.body).to include("ours")
      end
    end

    describe "the rail counts" do
      def rail_count_for(label)
        rail = response.body[/<nav id="junction-sidebar".*?<\/nav>/m]
        rail[/whitespace-nowrap">#{label}<\/span><span[^>]*tabular-nums[^>]*>\s*(\d+)/, 1]&.to_i
      end

      context "when the user may read every component" do
        it "counts them all" do
          get components_url

          expect(rail_count_for("Components")).to eq(Junction::Component.count)
        end
      end

      context "when the user may only read the ones their groups own" do
        let(:owned) { create(:group) }

        before do
          user = create_user_with_permissions([ "junction.codes/components.owned.read" ])
          create(:group_membership, user:, group: owned)
          create(:component, owner: owned)
          sign_in(user:, password: "Password1!")
        end

        it "counts only those" do
          get components_url

          expect(rail_count_for("Components"))
            .to eq(Junction::Component.where(owner: owned).count)
        end

        it "counts fewer than exist" do
          get components_url

          expect(rail_count_for("Components")).to be < Junction::Component.count
        end
      end
    end

    describe "DELETE /components/:id" do
      it_behaves_like "an action that requires permission",
        :delete, -> { component_path(component) },
        %w[junction.codes/components.all.destroy junction.codes/components.owned.destroy]

      it "destroys the requested component" do
        expect {
          delete component_path(component)
        }.to change(Junction::Component, :count).by(-1)
      end

      it "redirects to the components list" do
        delete component_path(component)
        expect(response).to redirect_to(components_url)
      end
    end
  end
end
