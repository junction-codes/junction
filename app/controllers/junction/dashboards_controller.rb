# frozen_string_literal: true

module Junction
  # Controller for user dashboards.
  class DashboardsController < ApplicationController
    include Junction::HasOwner

    CATALOG_ENTITIES = [ Api, Component, Domain, Resource, System ].freeze

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

    # Fetch catalog entities owned by groups the user is a member of.
    #
    # Results includes eager loaded associations for owner, domain, and system
    # where applicable.
    #
    # @return [Array<ApplicationRecord>] List of owned entities.
    def owned_entities
      group_ids = @user.deep_group_ids
      CATALOG_ENTITIES.map do |model|
        q = model.includes(:owner)
        q = q.includes(:domain) if model.reflect_on_association(:domain)
        q = q.includes(:system) if model.reflect_on_association(:system)
        q.where(owner_id: group_ids).to_a
      end.flatten.sort_by(&:name)
    end

    # Fetch recent updates to catalog entities.
    #
    # When fetching entities, access is checked to ensure we only include
    # entities that the user has permission to read.
    #
    # @param limit [Integer] Number of recent items to fetch.
    # @return [Array<ApplicationRecord>] List of recent catalog items.
    def recent_catalog_items(limit: 5)
      CATALOG_ENTITIES.flat_map do |model|
        q = index_scope_for(model)
        next [] if q.blank?

        q = q.includes(:domain) if model.reflect_on_association(:domain)
        q = q.includes(:system) if model.reflect_on_association(:system)
        q.includes(:owner).order(updated_at: :desc).limit(limit).to_a
      end.sort_by(&:updated_at).reverse.first(limit)
    end
  end
end
