# frozen_string_literal: true

# Shared examples for testing the dependency search action.
#
# @param source_factory [Symbol] Factory name for the source entity.
# @param path_method [Symbol] Route helper for the search path.
# @param read_permission [String] Permission string required to access the
#   source entity and its dependencies.
RSpec.shared_examples "a dependency search action" do |source_factory, path_method, read_permission|
  subject!(:source) { create(source_factory) }

  let(:path) { send(path_method, namespace: source.namespace, name: source.name) }

  context "when the user is not authenticated" do
    it_behaves_like "an action that requires authentication", :get, -> { path }
  end

  context "when the user is authenticated" do
    requires_authentication

    it_behaves_like "an action that requires permission",
      :get, -> { path }, [ read_permission ]

    context "with read permission" do
      before { sign_in_user_with_permissions([ read_permission ]) }

      it "returns a successful response" do
        get path
        expect(response).to be_successful
      end

      context "when searching by title" do
        # Use the same factory as the source so the read_permission covers
        # the target type without needing additional permissions.
        let!(:target) { create(source_factory) }

        it "includes entities matching the query" do
          get path, params: { q: target.title }
          expect(response.body).to include(target.title)
        end

        it "excludes entities that do not match the query" do
          get path, params: { q: "zzznomatch_#{SecureRandom.hex}" }
          expect(response.body).not_to include(target.title)
        end
      end
    end
  end
end
