class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    render Views::Users::Index.new(
      users: User.order(:display_name),
    )
  end

  # GET /users/1 or /users/1.json
  def show
    render Views::Users::Show.new(
      user: @user,
    )
  end

  # GET /users/new
  def new
    render Views::Users::New.new(
      user: User.new,
    )
  end

  # GET /users/1/edit
  def edit
    render Views::Users::Edit.new(
      user: @user,
    )
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, success: "User was successfully created."
    else
      flash.now[:alert] = "There were errors creating the user."
      render Views::Users::New.new(user: @user), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    if @user.update(user_update_params)
      redirect_to @user, success: "User was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the user."
      render Views::Users::Edit.new(user: @user), status: :unprocessable_entity
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    redirect_to users_path, status: :see_other, alert: "User was successfully deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.expect(user: [ :display_name, :email_address, :email_address_confirmation, :image_url, :password, :password_challenge, :password_confirmation, :pronouns ])
  end

  def user_update_params
    p = user_params
    p.delete(:password) if p[:password].blank?
    p.delete(:password_challenge) if p[:password].blank?

    p
  end
end
