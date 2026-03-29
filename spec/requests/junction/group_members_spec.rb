# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/groups/:group_id/members", type: :request do
  subject!(:group) { create(:group) }

  let!(:membership) { create(:group_membership, group:) }
  let!(:user) { create(:user) }
  let(:valid_params) { { member: { user_id: user.id } } }

  context "when the user is not authenticated" do
    describe "GET /members" do
      it_behaves_like "an action that requires authentication", :get,
        -> { group_members_path(group) }
    end

    describe "DELETE /members/:id" do
      it_behaves_like "an action that requires authentication", :delete,
        -> { group_member_path(group, membership.user) }
    end

    describe "POST /members" do
      it_behaves_like "an action that requires authentication", :post,
        -> { group_members_path(group) }
    end

    describe "GET /members/search" do
      it_behaves_like "an action that requires authentication", :get,
        -> { search_group_members_path(group) }
    end
  end

  context "when the user is authenticated" do
    requires_authentication

    describe "GET /members" do
      it_behaves_like "an action that requires permission",
        :get, -> { group_members_path(group) },
        %w[junction.codes/groups.all.read junction.codes/users.all.read]

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

    describe "DELETE /members/:id" do
      it_behaves_like "an action that requires permission",
        :delete, -> { group_member_path(group, membership.user) },
        %w[junction.codes/groups.all.write junction.codes/groups.owned.write
           junction.codes/users.all.read]

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

    describe "POST /members" do
      it_behaves_like "an action that requires permission",
          :post, -> { group_members_path(group) },
          %w[junction.codes/groups.all.write junction.codes/users.all.read],
          -> { valid_params }

      it "creates a group membership" do
        expect { post group_members_path(group), params: valid_params }
          .to change(Junction::GroupMembership, :count).by(1)
      end

      it "adds the correct user to the group" do
        post group_members_path(group), params: valid_params
        expect(group.members.reload).to include(user)
      end

      it "redirects with see_other status" do
        post group_members_path(group), params: valid_params
        expect(response).to have_http_status(:see_other)
      end

      it "does not create a duplicate membership" do
        create(:group_membership, group:, user:)

        expect { post group_members_path(group), params: valid_params }
          .not_to change(Junction::GroupMembership, :count)
      end
    end

    describe "GET /members/search" do
      it_behaves_like "an action that requires permission",
        :get, -> { search_group_members_path(group) },
        %w[junction.codes/groups.all.read junction.codes/users.all.read]

      it "returns a successful response" do
        get search_group_members_path(group)
        expect(response).to be_successful
      end

      context "when searching by name" do
        it "includes users matching the query" do
          get search_group_members_path(group), params: { q: user.display_name }

          expect(response.body).to include(user.display_name)
        end

        it "excludes users that do not match the query" do
          get search_group_members_path(group), params: { q: "zzznomatch_#{SecureRandom.hex}" }

          expect(response.body).not_to include(user.display_name)
        end
      end

      context "when a user is already a member" do
        before { group.members << user }

        it "excludes existing members from the results" do
          get search_group_members_path(group), params: { q: user.display_name }
          expect(response.body).not_to include(user.display_name)
        end
      end
    end
  end
end
