# frozen_string_literal: true

module Junction
  # Controller for managing Group member associations.
  class GroupMembersController < ApplicationController
    before_action :set_entity
    before_action :authorize_users_access!

    include Paginatable

    # GET /groups/:group_id/members
    def index
      authorize! @entity, to: :show?

      @q = @entity.members.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?
      @pagy, members = paginate(@q.result)

      can_edit = allowed_to?(:update?, @entity)
      render Views::Groups::Members.new(
        group: @entity,
        members:,
        pagy: @pagy,
        query: @q,
        can_destroy: can_edit,
        can_create: can_edit,
        create_url: can_edit ? junction_group_members_path(@entity) : nil,
        search_url: can_edit ? junction_search_group_members_path(@entity) : nil,
        page_url: ->(page) {
          junction_group_members_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit],
            q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_group_members_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_group_members_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # POST /groups/:group_id/members
    def create
      authorize! @entity, to: :update?

      user = User.find(member_params[:user_id])
      membership = @entity.group_memberships.build(user:)

      if membership.save
        redirect_back fallback_location: junction_group_members_path(@entity),
                      status: :see_other,
                      success: "User was successfully added to the group."
      else
        redirect_back fallback_location: junction_group_members_path(@entity),
                      status: :see_other,
                      alert: membership.errors.full_messages.to_sentence
      end
    end

    # GET /groups/:group_id/members/search
    def search
      authorize! @entity, to: :show?

      q = params[:q].to_s.strip
      excluded_ids = @entity.members.pluck(:id)

      results = User
        .where("title ILIKE ? OR email_address ILIKE ?", "%#{q}%", "%#{q}%")
        .where.not(id: excluded_ids)
        .order(:title)
        .limit(10)

      render Views::Groups::UserSearch.new(results:)
    end

    # DELETE /groups/:group_id/members/:id
    def destroy
      authorize! @entity, to: :update?
      @entity.group_memberships.find_by!(user_id: params.expect(:id)).destroy!

      redirect_back fallback_location: junction_group_members_path(@entity),
                    status: :see_other,
                    success: "User was successfully removed from the group."
    end

    private

    def set_entity
      @entity = Group.find_by!(namespace: params.expect(:namespace), name: params.expect(:name))
    end

    def authorize_users_access!
      authorize! User, to: :index_all?
    end

    def member_params
      params.expect(member: [ :user_id ])
    end
  end
end
