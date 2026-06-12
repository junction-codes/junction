# frozen_string_literal: true

module Junction
  # Controller for managing Domain catalog entities.
  class DomainsController < Junction::ApplicationController
    # Make sure the entity is set before any other helper methods are called.
    before_action :set_entity, only: %i[show edit update destroy systems]

    include Breadcrumbs
    include CatalogOptionSets
    include HasOwner
    include Paginatable

    # GET /domains
    def index
      authorize! Domain
      @q = index_scope_for(Domain).ransack(params[:q])
      @q.sorts = "title asc" if @q.sorts.empty?
      @pagy, domains = paginate(@q.result.includes(:parent, :owner))

      render Views::Domains::Index.new(
        domains:,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, Domain),
        available_owners:,
        available_statuses:,
        available_types:
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
      render Views::Domains::New.new(
        domain: Domain.new,
        breadcrumbs:,
        available_owners:,
        available_parents:,
        parent_editable: true,
        type_options: domain_type_options
      )
    end

    # GET /domains/:id/edit
    def edit
      authorize! @entity
      render Views::Domains::Edit.new(
        domain: @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        available_owners:,
        available_parents:,
        parent_editable: parent_editable?(@entity),
        type_options: domain_type_options
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
        render Views::Domains::New.new(
          domain: @entity,
          breadcrumbs:,
          available_owners:,
          available_parents:,
          parent_editable: parent_editable?(@entity),
          type_options: domain_type_options
        ), status: :unprocessable_content
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
          available_owners:,
          available_parents:,
          parent_editable: parent_editable?(@entity),
          type_options: domain_type_options
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

    # Returns an array of available types for domains.
    #
    # @return [Array<Array(String, String)>] Array of [name, key] pairs for
    #   types.
    def available_types
      CatalogOptions.domains.map { |key, opts| [ opts[:name], key ] }
    end

    # Options for the domain type field.
    #
    # @return [Hash] Hash of options.
    def domain_type_options
      catalog_options_for(
        Junction::CatalogOptions.domains,
        [ Junction::Domain, :domain_type ]
      )
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
      @entity = Domain.find_by!(namespace: params.expect(:namespace), name: params.expect(:name))
    end

    # Returns the available parents for the current Domain and user.
    #
    # @return [ActiveRecord::Relation<Domain>] List of parent candidates.
    def available_parents
      parent_candidates
    end

    # Computes the candidate parents for the current Domain.
    #
    # Excludes the entity itself and its descendants to prevent circular
    # hierarchy, and entities that the user doesn't have access to.
    #
    # @return [ActiveRecord::Relation<Domain>] Candidate parent domains.
    def parent_candidates
      scope = index_scope_for(Domain)
      return Domain.none unless scope

      scope = scope.select(:id, :title, :description, :image_url, :namespace, :name)
        .order(:title)
      return scope unless @entity&.persisted?

      scope.where.not(id: [ @entity.id, *@entity.descendant_ids ])
    end

    # Determines if the parent domain is editable for the given domain.
    #
    # @param domain [Domain] Domain whose parent will be checked.
    # @return [Boolean] Whether the user should be able to edit the parent.
    def parent_editable?(domain = @entity)
      domain.parent.blank? || allowed_to?(:show?, domain.parent)
    end

    def domain_params
      attrs = params.expect(domain: [
        :description, :domain_type, :image_url, :name, :namespace, :owner_id,
        :parent_id, :status, :title, :type
      ])
      sanitize_owner_id(sanitize_parent_id(attrs))
    end

    # Sanitizes the parent_id parameter.
    #
    # If the current Domain is persisted and the user is not allowed to edit the
    # parent, the parent_id is set to the current parent_id.
    #
    # @param attrs [Hash] Permitted parameters hash.
    # @return [Hash] Sanitized parameters hash.
    def sanitize_parent_id(attrs)
      out = attrs.dup
      return out unless out.key?("parent_id") || out.key?(:parent_id)

      id = out[:parent_id] || out["parent_id"]

      if @entity&.persisted? && !parent_editable?(@entity)
        out[:parent_id] = @entity.parent_id
        out["parent_id"] = out[:parent_id] if out.key?("parent_id")
        return out
      end

      out[:parent_id] = if id.blank?
        nil
      elsif parent_id_allowed?(id.to_i)
        id.to_i
      end

      out["parent_id"] = out[:parent_id] if out.key?("parent_id")
      out
    end

    # Determines if the submitted parent id is an allowed candidate.
    #
    # @param parent_id [Integer] Parent domain id.
    # @return [Boolean] Whether the parent id is allowed.
    def parent_id_allowed?(parent_id)
      return true if parent_id == @entity&.parent_id

      parent_candidates.where(id: parent_id).exists?
    end
  end
end
