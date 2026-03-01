# frozen_string_literal: true

module Junction
  # Controller for managing Users.
  class UsersController < Junction::ApplicationController
    before_action :set_entity, only: %i[ show edit update destroy ]

    # GET /users
    def index
      authorize! Junction::User
      @q = Junction::User.ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Users::Index.new(
        users: @q.result,
        query: @q,
        can_create: allowed_to?(:create?, Junction::User)
      )
    end

    # GET /users/:id
    def show
      authorize! @user
      render Views::Users::Show.new(
        user: @user,
        can_edit: allowed_to?(:update?, @user),
        can_destroy: allowed_to?(:destroy?, @user)
      )
    end

    # GET /users/new
    def new
      authorize! Junction::User
      render Views::Users::New.new(user: Junction::User.new)
    end

    # GET /users/:id/edit
    def edit
      authorize! @user
      render Views::Users::Edit.new(
        user: @user,
        can_destroy: allowed_to?(:destroy?, @user)
      )
    end

    # POST /users
    def create
      authorize! Junction::User
      @user = Junction::User.new(user_params)

      if @user.save
        redirect_to @user, success: "User was successfully created."
      else
        flash.now[:alert] = "There were errors creating the user."
        render Views::Users::New.new(user: @user), status: :unprocessable_content
      end
    end

    # PATCH/PUT /users/:id
    def update
      authorize! @user
      if @user.update(user_update_params)
        redirect_to @user, success: "User was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the user."
        render Views::Users::Edit.new(
          user: @user,
          can_destroy: allowed_to?(:destroy?, @user)
        ), status: :unprocessable_content
      end
    end

    # DELETE /users/:id
    def destroy
      authorize! @user
      @user.destroy!

      redirect_to users_path, status: :see_other, success: "User was successfully deleted."
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_entity
      @user = Junction::User.find(params.expect(:id))
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
