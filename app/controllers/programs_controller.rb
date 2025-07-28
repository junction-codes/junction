class ProgramsController < ApplicationController
  before_action :set_program, only: %i[show edit update destroy]

  # GET /programs
  def index
    render Views::Programs::Index.new(
      programs: Program.order(:name),
    )
  end

  # GET /programs/:id
  def show
    render Views::Programs::Show.new(
      program: @program,
    )
  end

  # GET /programs/new
  def new
    render Views::Programs::New.new(
      program: Program.new,
    )
  end

  # GET /programs/:id/edit
  def edit
    render Views::Programs::Edit.new(
      program: @program,
    )
  end

  # POST /programs
  def create
    @program = Program.new(program_params)

    if @program.save
      redirect_to @program, success: "Program was successfully created."
    else
      render Views::Programs::New.new(program: @program), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /programs/:id
  def update
    if @program.update(program_params)
      redirect_to @program, success: "Program was successfully updated."
    else
      render Views::Programs::Edit.new(program: @program), status: :unprocessable_entity
    end
  end

  # DELETE /programs/:id
  def destroy
    @program.destroy!

    respond_to do |format|
      format.html { redirect_to programs_path, status: :see_other, destructive: "Program was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_program
      @program = Program.find(params.expect(:id))
    end

    def program_params
      params.expect(program: [ :name, :description, :logo_url, :status ])
    end
end
