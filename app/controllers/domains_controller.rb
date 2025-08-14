class DomainsController < ApplicationController
  before_action :set_domain, only: %i[show edit update destroy]

  # GET /domains
  def index
    render Views::Domains::Index.new(
      domains: Domain.order(:name),
    )
  end

  # GET /domains/:id
  def show
    render Views::Domains::Show.new(
      domain: @domain,
    )
  end

  # GET /domains/new
  def new
    render Views::Domains::New.new(
      domain: Domain.new,
      owners: Group.order(:name)
    )
  end

  # GET /domains/:id/edit
  def edit
    render Views::Domains::Edit.new(
      domain: @domain,
      owners: Group.order(:name)
    )
  end

  # POST /domains
  def create
    @domain = Domain.new(domain_params)

    if @domain.save
      redirect_to @domain, success: "Domain was successfully created."
    else
      flash.now[:alert] = "There were errors creating the domain."
      render Views::Domains::New.new(domain: @domain, owners: @owners), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /domains/:id
  def update
    if @domain.update(domain_params)
      redirect_to @domain, success: "Domain was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the domain."
      render Views::Domains::Edit.new(domain: @domain, owners: Group.order(:name)), status: :unprocessable_entity
    end
  end

  # DELETE /domains/:id
  def destroy
    @domain.destroy!

    redirect_to domains_path, status: :see_other, alert: "Domain was successfully destroyed."
  end

  private

  def set_domain
    @domain = Domain.find(params.expect(:id))
  end

  def domain_params
    params.expect(domain: [ :name, :description, :image_url, :status, :owner_id ])
  end
end
