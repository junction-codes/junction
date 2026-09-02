# frozen_string_literal: true

module Junction
  # The seven CRUD actions every catalog entity controller shares.
  #
  # The controllers stay one-per-kind: routes, breadcrumbs, and the view
  # classes are all keyed on the controller name, and each kind's views take a
  # differently named argument. What they no longer carry is the action bodies,
  # which were identical apart from the model, the view namespace, and which
  # options the views want.
  #
  # A controller including this must define {#entity_class} and
  # {#create_params}. Everything else has a default.
  module CatalogEntityActions
    extend ActiveSupport::Concern

    include ReadScoped

    # Actions that operate on a single entity, and so need it loaded.
    MEMBER_ACTIONS = %i[show edit update destroy].freeze

    included do
      before_action :set_entity, only: MEMBER_ACTIONS
    end

    class_methods do
      # Loads the entity for extra member actions a controller adds.
      #
      # Registering `before_action :set_entity` a second time would replace the
      # first registration rather than add to it, silently leaving the standard
      # actions without an entity, so the full list is declared here in one go.
      #
      # @param actions [Array<Symbol>] Extra actions needing the entity.
      # @return [void]
      def load_entity_for(*actions)
        before_action :set_entity, only: MEMBER_ACTIONS + actions
      end
    end

    # GET /<plural>
    def index
      authorize! entity_class

      @q = index_relation.ransack(params[:q])
      @q.sorts = default_sort if @q.sorts.empty?
      results = @q.result
      results = results.includes(*index_includes) if index_includes.any?
      @pagy, records = paginate(results)

      render entity_view(:Index).new(
        collection_key => records,
        pagy: @pagy,
        query: @q,
        query_params: params[:q]&.to_unsafe_h || {},
        breadcrumbs:,
        can_create: allowed_to?(:create?, entity_class),
        **index_options
      )
    end

    # GET /<plural>/:namespace/:name
    def show
      authorize! @entity

      render entity_view(:Show).new(
        member_key => @entity,
        breadcrumbs:,
        can_edit: allowed_to?(:update?, @entity),
        can_destroy: allowed_to?(:destroy?, @entity),
        **show_options(@entity)
      )
    end

    # GET /<plural>/new
    def new
      authorize! entity_class

      record = entity_class.new
      render entity_view(:New).new(
        member_key => record, breadcrumbs:, **form_options(record)
      )
    end

    # GET /<plural>/:namespace/:name/edit
    def edit
      authorize! @entity

      render entity_view(:Edit).new(
        member_key => @entity,
        breadcrumbs:,
        can_destroy: allowed_to?(:destroy?, @entity),
        **form_options(@entity)
      )
    end

    # POST /<plural>
    def create
      authorize! entity_class
      @entity = entity_class.new(create_params)

      if @entity.save
        redirect_to junction_catalog_path(@entity), status: :see_other,
                    success: entity_message(:created)
      else
        flash.now[:alert] = entity_message(:create_failed)
        render entity_view(:New).new(
          member_key => @entity, breadcrumbs:, **form_options(@entity)
        ), status: :unprocessable_content
      end
    end

    # PATCH/PUT /<plural>/:namespace/:name
    def update
      authorize! @entity

      if @entity.update(update_params)
        redirect_to junction_catalog_path(@entity), status: :see_other,
                    success: entity_message(:updated)
      else
        flash.now[:alert] = entity_message(:update_failed)
        render entity_view(:Edit).new(
          member_key => @entity,
          breadcrumbs:,
          can_destroy: allowed_to?(:destroy?, @entity),
          **form_options(@entity)
        ), status: :unprocessable_content
      end
    end

    # DELETE /<plural>/:namespace/:name
    def destroy
      authorize! @entity
      @entity.destroy!

      redirect_to index_path, status: :see_other,
                  success: entity_message(:destroyed)
    end

    private

    # The model this controller manages.
    #
    # @return [Class] The entity class.
    # @raise [NotImplementedError] If not overridden.
    def entity_class
      raise NotImplementedError, "#{self.class} must define #entity_class"
    end

    # Permitted parameters for creating an entity.
    #
    # @return [ActionController::Parameters] The permitted parameters.
    # @raise [NotImplementedError] If not overridden.
    def create_params
      raise NotImplementedError, "#{self.class} must define #create_params"
    end

    # Permitted parameters for updating an entity.
    #
    # @return [ActionController::Parameters] The permitted parameters.
    def update_params
      create_params
    end

    # Relation the index lists, restricted to what the user may read.
    #
    # @return [ActiveRecord::Relation] The relation.
    def index_relation
      index_scope_for(entity_class)
    end

    # Associations to preload for the index.
    #
    # @return [Array<Symbol>] The associations.
    def index_includes
      []
    end

    # Default Ransack sort for the index.
    #
    # @return [String] The sort expression.
    def default_sort
      "title asc"
    end

    # Extra arguments for the index view.
    #
    # @return [Hash] The arguments.
    def index_options
      {}
    end

    # Extra arguments for the show view.
    #
    # @param entity [Junction::Entity] The entity being shown.
    # @return [Hash] The arguments.
    def show_options(entity)
      {}
    end

    # Extra arguments for the new and edit views.
    #
    # Both take the same options; `edit` adds `can_destroy` on top. The entity
    # is passed because option values can depend on it -- a tree kind decides
    # whether the parent may be reassigned from the record in hand.
    #
    # @param entity [Junction::Entity] The entity being edited, which may be
    #   unsaved.
    # @return [Hash] The arguments.
    def form_options(entity)
      {}
    end

    # Path of the index, used after a destroy.
    #
    # @return [String] The path.
    def index_path
      public_send(:"#{collection_key}_path")
    end

    # Loads the entity named by the route.
    def set_entity
      @entity = entity_class.find_by!(
        namespace: params.expect(:namespace), name: params.expect(:name)
      )
    end

    # View class for an action within this kind's view namespace.
    #
    # @param action [Symbol] The view name, e.g. +:Index+.
    # @return [Class] The view class.
    def entity_view(action)
      Junction::Views.const_get(collection_key.to_s.camelize).const_get(action)
    end

    # Argument name a collection view expects, e.g. +:apis+.
    #
    # @return [Symbol] The argument name.
    def collection_key
      entity_class.model_name.route_key.to_sym
    end

    # Argument name a member view expects, e.g. +:api+.
    #
    # @return [Symbol] The argument name.
    def member_key
      entity_class.model_name.param_key.to_sym
    end

    # Flash message for an outcome, named for this kind.
    #
    # @param key [Symbol] The message key.
    # @return [String] The message.
    def entity_message(key)
      t("junction.catalog.#{key}", name: entity_class.model_name.human)
    end
  end
end
