# frozen_string_literal: true

# Controller for managing Domain catalog entities.
class DomainsController < ApplicationController
  before_action :set_entity, only: %i[show edit update destroy]

  # GET /domains
  def index
    @q = Domain.ransack(params[:q])
    @q.sorts = "name asc" if @q.sorts.empty?

    render Views::Domains::Index.new(
      domains: @q.result,
      query: @q,
      available_owners:,
      available_statuses:
    )
  end

  # GET /domains/:id
  def show
    render Views::Domains::Show.new(domain: @domain)
  end

  # GET /domains/new
  def new
    render Views::Domains::New.new(domain: Domain.new, available_owners:)
  end

  # GET /domains/:id/edit
  def edit
    render Views::Domains::Edit.new(domain: @domain, available_owners:)
  end

  # POST /domains
  def create
    @domain = Domain.new(domain_params)

    if @domain.save
      redirect_to @domain, success: "Domain was successfully created."
    else
      flash.now[:alert] = "There were errors creating the domain."
      render Views::Domains::New.new(domain: @domain, available_owners:), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /domains/:id
  def update
    if @domain.update(domain_params)
      redirect_to @domain, success: "Domain was successfully updated."
    else
      flash.now[:alert] = "There were errors updating the domain."
      render Views::Domains::Edit.new(domain: @domain, available_owners:), status: :unprocessable_entity
    end
  end

  # DELETE /domains/:id
  def destroy
    @domain.destroy!

    redirect_to domains_path, status: :see_other, alert: "Domain was successfully destroyed."
  end

  private

  # Returns a collection of available owners for domains.
  #
  # @return [ActiveRecord::Relation] Collection of owners.
  def available_owners
    Group.select(:description, :id, :image_url, :name).order(:name)
  end

  # Returns an array of available statuses for domains.
  #
  # @return [Array<Array(String, String)>] Array of [label, value] pairs for
  #   statuses.
  def available_statuses
    Domain.validators_on(:status).find do |v|
      v.is_a?(ActiveModel::Validations::InclusionValidator)
    end&.options[:in]&.map { |s| [ s.capitalize, s ] } || []
  end

  def set_entity
    @domain = Domain.find(params.expect(:id))
  end

  def domain_params
    params.expect(domain: [ :name, :description, :image_url, :status, :owner_id ])
  end
end
