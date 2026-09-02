# frozen_string_literal: true

module Junction
  # Controller for user dashboards.
  class DashboardsController < ApplicationController
    include ReadScoped

    before_action :set_user

    # GET /dashboard
    def show
      authorize! :dashboard
      render Views::Dashboards::Show.new(
        user: @user,
        owned_entities:,
        recent_catalog_items:
      )
    end

    private

    def set_user
      @user = Current.user
    end

    # Fetch catalog entities owned by the user or by groups they belong to.
    #
    # @return [Array<Junction::Entity>] List of owned entities.
    def owned_entities
      Entity.catalog
            .where(owner_id: @user.owner_ids)
            .includes(:owner, :domain, :system)
            .order(:name)
            .to_a
    end

    # Fetch recent updates to catalog entities.
    #
    # Access is checked per kind, so only entities the user has permission to
    # read are included.
    #
    # @param limit [Integer] Number of recent items to fetch.
    # @return [Array<Junction::Entity>] List of recent catalog items.
    def recent_catalog_items(limit: 5)
      entity_scope_for(Junction::Kinds.catalog)
        .includes(:owner, :domain, :system)
        .order(updated_at: :desc)
        .limit(limit)
        .to_a
    end
  end
end
