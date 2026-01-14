# frozen_string_literal: true

class RenameTablesToJunctionNamespace < ActiveRecord::Migration[8.1]
  def change
    rename_table :users, :junction_users
    rename_table :sessions, :junction_sessions
    rename_table :groups, :junction_groups
    rename_table :group_memberships, :junction_group_memberships
    rename_table :components, :junction_components
    rename_table :apis, :junction_apis
    rename_table :resources, :junction_resources
    rename_table :systems, :junction_systems
    rename_table :domains, :junction_domains
    rename_table :deployments, :junction_deployments
    rename_table :identities, :junction_identities
    rename_table :dependencies, :junction_dependencies
  end
end
