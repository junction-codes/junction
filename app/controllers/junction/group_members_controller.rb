# frozen_string_literal: true

module Junction
  # Controller for managing Group member associations.
  class GroupMembersController < ApplicationController
    before_action :set_entity

    include Paginatable

    # GET /groups/:group_id/members
    def index
      authorize! @entity, to: :show?

      @q = @entity.members.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?
      @pagy, members = paginate(@q.result)

      can_destroy = allowed_to?(:update?, @entity)
      render Views::Groups::Members.new(
        group: @entity,
        members:,
        pagy: @pagy,
        query: @q,
        can_destroy:,
        page_url: ->(page) {
          group_members_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          group_members_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          group_members_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # DELETE /groups/:group_id/members/:user_id
    def destroy
      authorize! @entity, to: :update?
      @entity.group_memberships.find_by!(user_id: params.expect(:id)).destroy!

      redirect_back fallback_location: group_members_path(@entity),
                    status: :see_other,
                    success: "User was successfully removed from the group."
    end

    private

    def set_entity
      @entity = Group.find(params.expect(:group_id))
    end
  end
end
