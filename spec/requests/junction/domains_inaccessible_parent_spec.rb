# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/domains owned child with inaccessible parent", type: :request do
  let(:user) do
    create_user_with_permissions(%w[
      junction.codes/domains.owned.read
      junction.codes/domains.owned.write
    ])
  end
  let(:user_group) { create(:group) }
  let!(:inaccessible_parent) do
    create(:domain, title: "Parent Area", name: "scoped-parent-area", owner: create(:group))
  end
  let!(:owned_child) do
    create(:domain, title: "Child Group", name: "scoped-child-group",
                   parent: inaccessible_parent, owner: user_group)
  end

  before do
    create(:group_membership, user:, group: user_group)
    sign_in(user: user, password: "Password1!")
  end

  it "shows the parent title on show" do
    get domain_path(owned_child)

    expect(response.body).to include("Part of the &#39;Parent Area&#39; Domain")
  end

  it "does not link to the inaccessible parent on show" do
    get domain_path(owned_child)

    expect(response.body).not_to include(domain_path(inaccessible_parent))
  end

  it "renders a hidden parent_id field on edit" do
    get edit_domain_path(owned_child)

    expect(response.body).to include("domain[parent_id]")
  end

  it "preserves the hidden parent_id value on edit" do
    get edit_domain_path(owned_child)

    expect(response.body).to include("value=\"#{inaccessible_parent.id}\"")
  end

  it "preserves parent_id when updating other fields" do
    patch domain_path(owned_child), params: {
      domain: { description: "Updated description", parent_id: "" }
    }

    expect(owned_child.reload.parent_id).to eq(inaccessible_parent.id)
  end
end
