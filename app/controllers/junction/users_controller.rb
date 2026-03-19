# frozen_string_literal: true

module Junction
  # Controller for managing Users.
  class UsersController < ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[ show edit update destroy ]

    include Breadcrumbs
    include Paginatable

    # GET /users
    def index
      authorize! User
      @q = User.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?
      @pagy, users = paginate(@q.result)

      render Views::Users::Index.new(
        users:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, User)
      )
    end

    # GET /users/:id
    def show
      authorize! @entity
      render Views::Users::Show.new(
        user: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # GET /users/new
    def new
      authorize! User
      render Views::Users::New.new(user: User.new, breadcrumbs:)
    end

    # GET /users/:id/edit
    def edit
      authorize! @entity
      render Views::Users::Edit.new(
        user: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # POST /users
    def create
      authorize! User
      @entity = User.new(user_params)

      if @entity.save
        redirect_to @entity, success: "User was successfully created."
      else
        flash.now[:alert] = "There were errors creating the user."
        render Views::Users::New.new(user: @entity, breadcrumbs:), status: :unprocessable_content
      end
    end

    # PATCH/PUT /users/:id
    def update
      authorize! @entity
      if @entity.update(user_update_params)
        redirect_to @entity, success: "User was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the user."
        render Views::Users::Edit.new(
          user: @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity)
        ), status: :unprocessable_content
      end
    end

    # DELETE /users/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to users_path, status: :see_other, success: "User was successfully destroyed."
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_entity
      @entity = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [
        :display_name, :email_address, :email_address_confirmation, :image_url,
        :password, :password_challenge, :password_confirmation, :pronouns,
        :owner_id, annotations: {}
      ])
    end

    def user_update_params
      p = user_params
      p.delete(:password) if p[:password].blank?
      p.delete(:password_challenge) if p[:password].blank?

      p
    end
  end
end
