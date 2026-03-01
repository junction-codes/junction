# frozen_string_literal: true

module Junction
  # Controller for managing Domain catalog entities.
  class DomainsController < Junction::ApplicationController
    include Junction::HasOwner

    before_action :set_entity, only: %i[show edit update destroy]

    # GET /domains
    def index
      authorize! Junction::Domain
      @q = index_scope_for(Junction::Domain).ransack(params[:q])
      @q.sorts = "name asc" if @q.sorts.empty?

      render Views::Domains::Index.new(
        domains: @q.result,
        query: @q,
        can_create: allowed_to?(:create?, Junction::Domain),
        available_owners:,
        available_statuses:
      )
    end

    # GET /domains/:id
    def show
      authorize! @entity
      render Views::Domains::Show.new(
        domain: @entity,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # GET /domains/new
    def new
      authorize! Junction::Domain
      render Views::Domains::New.new(domain: Junction::Domain.new, available_owners:)
    end

    # GET /domains/:id/edit
    def edit
      authorize! @entity
      render Views::Domains::Edit.new(
        domain: @entity,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:
      )
    end

    # POST /domains
    def create
      authorize! Junction::Domain
      @entity = Junction::Domain.new(domain_params)

      if @entity.save
        redirect_to @entity, success: "Domain was successfully created."
      else
        flash.now[:alert] = "There were errors creating the domain."
        render Views::Domains::New.new(domain: @entity, available_owners:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /domains/:id
    def update
      authorize! @entity
      if @entity.update(domain_params)
        redirect_to @entity, success: "Domain was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the domain."
        render Views::Domains::Edit.new(
          domain: @entity,
          can_destroy: allowed_to?(:destroy?, @entity),
          available_owners:
        ), status: :unprocessable_content
      end
    end

    # DELETE /domains/:id
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to domains_path, status: :see_other, success: "Domain was successfully destroyed."
    end

    private

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
      @entity = Junction::Domain.find(params.expect(:id))
    end

    def domain_params
      sanitize_owner_id(params.expect(domain: [
        :name, :description, :image_url, :status, :owner_id
      ]))
    end
  end
end
