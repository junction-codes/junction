# frozen_string_literal: true

module Junction
  # Controller for managing Domain catalog entities.
  class DomainsController < Junction::ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[show edit update destroy systems]

    include Breadcrumbs
    include HasOwner
    include Paginatable
    include RedirectsLegacySluggableMember

    redirects_legacy_sluggable "/domains", Domain

    # GET /domains
    def index
      authorize! Domain
      @q = index_scope_for(Domain).ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, domains = paginate(@q.result)

      render Views::Domains::Index.new(
        domains:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Domain),
        available_owners:,
        available_statuses:
      )
    end

    # GET /domains/:id/systems
    def systems
      authorize! @entity, to: :show?
      @q = @entity.systems.ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, systems = paginate(@q.result)

      render Views::Domains::Systems.new(
        systems:,
        pagy: @pagy,
        query: @q,
        page_url: ->(page) {
          junction_systems_domain_path(
            @entity,
            page:,
            per_page: @pagy.options[:limit], q: params[:q]&.to_unsafe_h
          )
        },
        per_page_url: ->(per_page) {
          junction_systems_domain_path(@entity, per_page:, q: params[:q]&.to_unsafe_h)
        },
        sort_url: ->(field, direction) {
          junction_systems_domain_path(
            @entity,
            q: (params[:q]&.to_unsafe_h || {}).merge("s" => "#{field} #{direction}"),
            per_page: @pagy.options[:limit]
          )
        }
      )
    end

    # GET /domains/:id
    def show
      authorize! @entity
      render Views::Domains::Show.new(
        domain: @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity)
      )
    end

    # GET /domains/new
    def new
      authorize! Domain
      render Views::Domains::New.new(domain: Domain.new, breadcrumbs:,
                                     available_owners:)
    end

    # GET /domains/:id/edit
    def edit
      authorize! @entity
      render Views::Domains::Edit.new(
        domain: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:
      )
    end

    # POST /domains
    def create
      authorize! Domain
      @entity = Domain.new(domain_params)

      if @entity.save
        redirect_to junction_catalog_path(@entity), success: "Domain was successfully created."
      else
        flash.now[:alert] = "There were errors creating the domain."
        render Views::Domains::New.new(domain: @entity, breadcrumbs:, available_owners:),
               status: :unprocessable_content
      end
    end

    # PATCH/PUT /domains/:id
    def update
      authorize! @entity
      if @entity.update(domain_params)
        redirect_to junction_catalog_path(@entity), success: "Domain was successfully updated."
      else
        flash.now[:alert] = "There were errors updating the domain."
        render Views::Domains::Edit.new(
          domain: @entity,
          breadcrumbs:,
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
      @entity = Domain.find_by!(namespace: params.expect(:namespace), name: params.expect(:name))
    end

    def domain_params
      sanitize_owner_id(params.expect(domain: [
        :description, :image_url, :name, :namespace, :owner_id, :status, :title
      ]))
    end
  end
end
