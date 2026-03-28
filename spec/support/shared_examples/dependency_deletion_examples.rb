# frozen_string_literal: true

# Shared examples for testing dependency deletion.
#
# @param source_factory [Symbol] Factory name for the source entity.
# @param write_permission [String] Permission string required to delete the
#   dependency.
RSpec.shared_examples "a dependency deletion action" do |source_factory, write_permission|
  subject!(:dependency) { create(:dependency, source: create(source_factory)) }

  context "when the user is not authenticated" do
    it_behaves_like "an action that requires authentication", :delete,
      -> { dependency_path(dependency) }
  end

  context "when the user is authenticated" do
    requires_authentication

    it_behaves_like "an action that requires permission",
      :delete, -> { dependency_path(dependency) }, [ write_permission ]

    it "destroys the dependency record" do
      expect { delete dependency_path(dependency) }
        .to change(Junction::Dependency, :count).by(-1)
    end

    it "does not destroy the source entity" do
      source = dependency.source
      delete dependency_path(dependency)
      expect(source.class.exists?(source.id)).to be true
    end

    it "does not destroy the target entity" do
      target = dependency.target
      delete dependency_path(dependency)
      expect(target.class.exists?(target.id)).to be true
    end

    it "redirects with see_other status" do
      delete dependency_path(dependency)
      expect(response).to have_http_status(:see_other)
    end
  end
end
