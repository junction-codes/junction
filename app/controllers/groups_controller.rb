class GroupsController < ApplicationController
  before_action :set_entity, only: %i[ show edit update destroy ]

  # GET /groups or /groups.json
  def index
    render Views::Groups::Index.new(
      groups: Group.order(:name),
    )
  end

  # GET /groups/1 or /groups/1.json
  def show
    render Views::Groups::Show.new(
      group: @group,
    )
  end

  # GET /groups/new
  def new
    render Views::Groups::New.new(
      group: Group.new,
      parents: Group.order(:name),
    )
  end

  # GET /groups/1/edit
  def edit
    render Views::Groups::Edit.new(
      group: @group,
      parents: Group.where.not(id: @group.id).order(:name),
    )
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, success: "Group was successfully created."
    else
      flash.now[:alert] = "There were errors creating the group."
      render Views::Groups::New.new(group: @group, parents: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    if @group.update(group_params)
      redirect_to @group, success: "Group was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the group."
      render Views::Groups::Edit.new(group: @group, parents: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy!

    redirect_to groups_path, status: :see_other, alert: "Group was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_entity
    @group = Group.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.expect(group: [ :description, :name, :email, :image_url, :parent_id, :type, annotations: {} ])
  end
end
