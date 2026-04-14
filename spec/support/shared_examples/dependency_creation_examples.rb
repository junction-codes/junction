# frozen_string_literal: true

# Shared examples for testing the dependency creation action.
#
# @param source_factory [Symbol] Factory name for the source entity.
# @param path_method [Symbol] Route helper method name for the dependencies
#   path.
# @param write_permission [String] Permission string required to create a
#   dependency.
RSpec.shared_examples "a dependency creation action" do |source_factory, path_method, write_permission|
  subject!(:source) { create(source_factory) }

  let!(:target) { create(:api) }
  let(:path) { send(path_method, namespace: source.namespace, name: source.name) }
  let(:valid_params) { { dependency: { target: "Junction::Api:#{target.id}" } } }

  context "when the user is not authenticated" do
    it_behaves_like "an action that requires authentication", :post,
      -> { path }
  end

  context "when the user is authenticated" do
    requires_authentication

    it_behaves_like "an action that requires permission",
      :post, -> { path }, [ write_permission ], -> { valid_params }

    context "with write permission" do
      before { sign_in_user_with_permissions([ write_permission ]) }

      it "creates a dependency" do
        expect { post path, params: valid_params }
          .to change(Junction::Dependency, :count).by(1)
      end

      it "sets the correct source" do
        post path, params: valid_params
        expect(Junction::Dependency.last.source).to eq(source)
      end

      it "sets the correct target" do
        post path, params: valid_params
        expect(Junction::Dependency.last.target).to eq(target)
      end

      it "redirects with see_other status" do
        post path, params: valid_params
        expect(response).to have_http_status(:see_other)
      end

      it "does not create a dependency with a blank target" do
        expect { post path, params: { dependency: { target: "" } } }
          .not_to change(Junction::Dependency, :count)
      end
    end
  end
end
