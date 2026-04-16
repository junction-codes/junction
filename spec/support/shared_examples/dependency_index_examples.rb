# frozen_string_literal: true

# Shared examples for testing the dependencies index action.
#
# @param source_factory [Symbol] Factory name for the source entity.
# @param path_method [Symbol] Route helper method name for the index path.
# @param read_permission [String] Permission string required to view the
#   dependencies.
RSpec.shared_examples "a dependency index action" do |source_factory, path_method, read_permission|
  subject!(:source) { create(source_factory) }

  let(:entity_dependencies_path) { send(path_method, namespace: source.namespace, name: source.name) }

  context "when the user is not authenticated" do
    it_behaves_like "an action that requires authentication", :get,
      -> { entity_dependencies_path }
  end

  context "when the user is authenticated" do
    requires_authentication

    it_behaves_like "an action that requires permission",
      :get, -> { entity_dependencies_path }, [ read_permission ]

    it_behaves_like "a paginated index",
      -> { entity_dependencies_path },
      -> { source.dependent_apis.count },
      :dependency,
      -> { { source: } }

    it "renders a successful response" do
      get entity_dependencies_path
      expect(response).to be_successful
    end
  end
end
