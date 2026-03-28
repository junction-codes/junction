# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/groups/:group_id/members", type: :request do
  subject!(:group) { create(:group) }

  let!(:membership) { create(:group_membership, group:) }

  context "when the user is not authenticated" do
    describe "GET /index" do
      it_behaves_like "an action that requires authentication", :get,
        -> { group_members_path(group) }
    end

    describe "DELETE /destroy" do
      it_behaves_like "an action that requires authentication", :delete,
        -> { group_member_path(group, membership.user) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /index" do
      it_behaves_like "an action that requires permission",
        :get, -> { group_members_path(group) }, %w[junction.codes/groups.all.read]

      it_behaves_like "a paginated index",
        -> { group_members_path(group) },
        -> { group.members.count },
        :group_membership,
        -> { { group: } }

      it "renders a successful response" do
        get group_members_url(group)
        expect(response).to be_successful
      end
    end

    describe "DELETE /destroy" do
      it_behaves_like "an action that requires permission",
        :delete, -> { group_member_path(group, membership.user) },
        %w[junction.codes/groups.all.write junction.codes/groups.owned.write]

      it "destroys the group membership" do
        expect { delete group_member_path(group, membership.user) }
          .to change(Junction::GroupMembership, :count).by(-1)
      end

      it "does not destroy the user" do
        user = membership.user
        delete group_member_path(group, membership.user)

        expect(Junction::User.exists?(user.id)).to be true
      end

      it "redirects with see_other status" do
        delete group_member_path(group, membership.user)
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
