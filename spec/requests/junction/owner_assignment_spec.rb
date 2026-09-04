# frozen_string_literal: true

require "rails_helper"

# Naming an owner grants that owner `owned` access to the entity, so who may
# be named is gated. Users holding write access to every entity of a kind can
# already edit all of them, so they may name anyone; users holding only
# `owned` write are held to owners they are part of.
RSpec.describe "owner assignment", type: :request do
  include AuthenticationHelper

  let!(:unrelated_group) { create(:group, title: "Unrelated Team") }
  let!(:unrelated_user) { create(:user, title: "Unrelated Person") }

  let(:attributes) do
    {
      title: "Owned API",
      description: "An API for testing ownership",
      definition: "{}",
      lifecycle: "experimental",
      type: "openapi",
      system_id: create(:system).id
    }
  end

  def created_api
    Junction::Api.find_by(title: "Owned API")
  end

  context "with write access to every API" do
    before { sign_in_user_with_permissions(%w[junction.codes/apis.all.write]) }

    it "assigns a group the user does not belong to" do
      post apis_path, params: { api: attributes.merge(owner_id: unrelated_group.id) }
      expect(created_api.owner).to eq(unrelated_group)
    end

    it "assigns another user" do
      post apis_path, params: { api: attributes.merge(owner_id: unrelated_user.id) }
      expect(created_api.owner).to eq(unrelated_user)
    end

    it "offers a group the user does not belong to" do
      get new_api_path
      expect(response.body).to include(unrelated_group.title)
    end

    it "still rejects an owner that is neither a group nor a user" do
      post apis_path, params: { api: attributes.merge(owner_id: create(:component).id) }
      expect(created_api).to be_nil
    end
  end

  context "with write access only to owned APIs" do
    let!(:user) { sign_in_user_with_permissions(%w[junction.codes/apis.owned.write]) }

    it "assigns a group the user belongs to" do
      post apis_path, params: { api: attributes.merge(owner_id: user.groups.first.id) }
      expect(created_api.owner).to eq(user.groups.first)
    end

    it "assigns the user themselves" do
      post apis_path, params: { api: attributes.merge(owner_id: user.id) }
      expect(created_api.owner).to eq(user)
    end

    it "does not offer a group the user does not belong to" do
      get new_api_path
      expect(response.body).not_to include(unrelated_group.title)
    end

    it "refuses a group the user does not belong to" do
      post apis_path, params: { api: attributes.merge(owner_id: unrelated_group.id) }
      expect(created_api).to be_nil
    end

    it "refuses another user" do
      post apis_path, params: { api: attributes.merge(owner_id: unrelated_user.id) }
      expect(created_api).to be_nil
    end
  end
end
