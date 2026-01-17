# frozen_string_literal: true

class CreateJunctionInitial < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_catalog.plpgsql"

    create_table :junction_groups do |t|
      t.jsonb :annotations
      t.text :description, null: false
      t.string :email
      t.string :group_type, null: false
      t.string :image_url
      t.string :name, null: false
      t.references :parent, foreign_key: { to_table: :junction_groups }
      t.timestamps null: false
    end

    create_table :junction_users do |t|
      t.jsonb :annotations
      t.string :display_name, null: false
      t.string :email_address, null: false
      t.string :image_url
      t.string :password_digest, null: false
      t.string :pronouns
      t.timestamps null: false
    end
    add_index :junction_users, :email_address, unique: true

    create_table :junction_domains do |t|
      t.text :description
      t.string :image_url
      t.string :name
      t.references :owner, foreign_key: { to_table: :junction_groups }
      t.string :status
      t.timestamps null: false
    end

    create_table :junction_systems do |t|
      t.text :description
      t.references :domain, null: false, foreign_key: { to_table: :junction_domains }
      t.string :image_url
      t.string :name
      t.references :owner, foreign_key: { to_table: :junction_groups }
      t.string :status
      t.timestamps null: false
    end

    create_table :junction_components do |t|
      t.jsonb :annotations
      t.string :component_type
      t.text :description
      t.string :image_url
      t.string :lifecycle
      t.string :name
      t.references :owner, foreign_key: { to_table: :junction_groups }
      t.string :repository_url
      t.references :system, foreign_key: { to_table: :junction_systems }
      t.timestamps null: false
    end

    create_table :junction_deployments do |t|
      t.references :component, null: false, foreign_key: { to_table: :junction_components }
      t.string :environment
      t.string :location_identifier
      t.string :platform
      t.timestamps null: false
    end

    create_table :junction_dependencies do |t|
      t.references :source, null: false, polymorphic: true, index: true
      t.references :target, null: false, polymorphic: true, index: true
      t.timestamps null: false
    end

    create_table :junction_resources do |t|
      t.jsonb :annotations
      t.text :description
      t.string :image_url
      t.string :name
      t.references :owner, null: false, foreign_key: { to_table: :junction_groups }
      t.string :resource_type
      t.references :system, null: false, foreign_key: { to_table: :junction_systems }
      t.timestamps null: false
    end

    create_table :junction_apis do |t|
      t.jsonb :annotations
      t.string :api_type
      t.text :definition
      t.text :description
      t.string :image_url
      t.string :lifecycle
      t.string :name
      t.references :owner, null: false, foreign_key: { to_table: :junction_groups }
      t.references :system, null: false, foreign_key: { to_table: :junction_systems }
      t.timestamps null: false
    end

    create_table :junction_group_memberships do |t|
      t.references :group, null: false, foreign_key: { to_table: :junction_groups }
      t.references :user, null: false, foreign_key: { to_table: :junction_users }
      t.timestamps null: false
    end

    create_table :junction_identities do |t|
      t.string :provider
      t.string :uid
      t.references :user, null: false, foreign_key: { to_table: :junction_users }
      t.timestamps null: false
    end

    create_table :junction_sessions do |t|
      t.string :ip_address
      t.string :user_agent
      t.references :user, null: false, foreign_key: { to_table: :junction_users }
      t.timestamps null: false
    end
  end
end
