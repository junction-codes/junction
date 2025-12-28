class GroupsController < ApplicationController
  before_action :set_entity, only: %i[ show edit update destroy ]

  # GET /groups or /groups.json
  def index
    @q = Group.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?

    render Views::Groups::Index.new(
      groups: @q.result,
      query: @q,
      available_types:,
    )
  end

  # GET /groups/1 or /groups/1.json
  def show
    render Views::Groups::Show.new(group: @group)
  end

  # GET /groups/new
  def new
    render Views::Groups::New.new(group: Group.new, available_parents:)
  end

  # GET /groups/1/edit
  def edit
    render Views::Groups::Edit.new(group: @group, available_parents:)
  end

  # POST /groups or /groups.json
  def create
    @group = Group.new(group_params)

    if @group.save
      redirect_to @group, success: "Group was successfully created."
    else
      flash.now[:alert] = "There were errors creating the group."
      render Views::Groups::New.new(group: @group, available_parents:), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    if @group.update(group_params)
      redirect_to @group, success: "Group was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the group."
      render Views::Groups::Edit.new(group: @group, available_parents:), status: :unprocessable_entity
    end
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy!

    redirect_to groups_path, status: :see_other, alert: "Group was successfully destroyed."
  end

  private

  # Returns a collection of available parents for groups.
  #
  # @return [ActiveRecord::Relation] Collection of parents.
  def available_parents
    Group.select(:description, :id, :image_url, :name).order(:name)
  end

  # Returns an array of available types for groups.
  #
  # @return [Array<Array(String, String)>] Array of [name, key] pairs for
  #   types.
  def available_types
    CatalogOptions.group_types.map { |key, opts| [ opts[:name], key ] }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_entity
    @group = Group.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def group_params
    params.expect(group: [ :description, :name, :email, :image_url, :parent_id, :type, annotations: {} ])
  end
end
