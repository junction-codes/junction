# frozen_string_literal: true

module Junction
  # Controller for user dashboards.
  class DashboardsController < ApplicationController
    CATALOG_ENTITIES = [ Api, Component, Domain, Resource, System ].freeze

    before_action :set_user

    # GET /dashboard
    def show
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
    # Results includes eager loaded associations for owner, domain, and system
    # where applicable.
    #
    # @param limit [Integer] Number of recent items to fetch.
    # @return [Array<ApplicationRecord>] List of recent catalog items.
    def recent_catalog_items(limit: 5)
      CATALOG_ENTITIES.map do |model|
        q = model.includes(:owner)
        q = q.includes(:domain) if model.reflect_on_association(:domain)
        q = q.includes(:system) if model.reflect_on_association(:system)
        q.order(updated_at: :desc).limit(limit).to_a
      end.flatten.sort_by(&:updated_at).reverse.first(limit)
    end
  end
end
