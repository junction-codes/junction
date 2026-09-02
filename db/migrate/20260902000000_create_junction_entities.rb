# frozen_string_literal: true

# Collapses the per-kind catalog tables into a single `junction_entities` table
# using single table inheritance, keyed by a `kind` discriminator.
#
# The polymorphic `junction_dependencies` table becomes `junction_relations`
# with real foreign keys, now that every entity shares one table. Password
# digests move to `junction_credentials` so the one genuinely secret column no
# longer sits beside public catalog data. Addresses stay on the entity as
# `email`, which is what Backstage's `spec.profile.email` means for both users
# and groups, and which several queries and filters read directly.
#
# Rows are copied with their source table and primary key recorded in temporary
# `legacy_*` columns, which is how intra-entity references are remapped without
# a separate mapping table. Those columns, along with the constraints that
# depend on clean data, are only added after verification passes.
class CreateJunctionEntities < ActiveRecord::Migration[8.1]
  # Source table => STI discriminator value. Ordering is irrelevant: no
  # constraints are active until every row has been copied.
  SOURCE_TABLES = {
    "junction_groups" => "Group",
    "junction_users" => "User",
    "junction_roles" => "Role",
    "junction_domains" => "Domain",
    "junction_systems" => "System",
    "junction_resources" => "Resource",
    "junction_components" => "Component",
    "junction_apis" => "Api"
  }.freeze

  # Legacy reference column => table the reference pointed at. `parent_id` is
  # absent because a parent always lives in the same table as its child.
  REMAPPED_REFERENCES = {
    "owner_id" => "junction_groups",
    "system_id" => "junction_systems",
    "domain_id" => "junction_domains",
    "role_id" => "junction_roles"
  }.freeze

  # Dependency `source_type`/`target_type` value => source table.
  DEPENDENCY_TABLES = {
    "Junction::Api" => "junction_apis",
    "Junction::Component" => "junction_components",
    "Junction::Resource" => "junction_resources"
  }.freeze

  def up
    counts = SOURCE_TABLES.keys.index_with { |table| count_rows(table) }

    create_entities_table
    create_relations_table
    create_credentials_table

    copy_groups
    copy_users
    copy_roles
    copy_domains
    copy_systems
    copy_resources
    copy_components
    copy_apis

    remap_entity_references
    backfill_credentials
    backfill_relations
    remap_external_references

    verify_counts!(counts)
    verify_no_dangling_references!

    finalize_entities_table
    finalize_relations_table
    finalize_external_references

    drop_table :junction_apis
    drop_table :junction_components
    drop_table :junction_resources
    drop_table :junction_systems
    drop_table :junction_domains
    drop_table :junction_groups
    drop_table :junction_users
    drop_table :junction_roles
    drop_table :junction_dependencies
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Collapsing catalog tables into junction_entities cannot be reversed."
  end

  private

  # --- Table creation -------------------------------------------------------

  def create_entities_table
    create_table :junction_entities do |t|
      t.string :kind, null: false
      t.string :namespace, null: false, default: "default"
      t.string :name, null: false
      t.string :title, null: false
      t.text :description
      t.string :image_url

      t.jsonb :annotations, null: false, default: {}
      t.jsonb :labels, null: false, default: {}
      t.jsonb :links, null: false, default: []
      t.string :tags, null: false, default: [], array: true

      # Catalog type vocabulary. Not the STI discriminator -- the model sets
      # `inheritance_column` to "kind", which leaves `type` free to keep its
      # existing meaning in forms, filters, and Ransack queries.
      t.string :type
      t.string :lifecycle

      t.bigint :owner_id
      t.bigint :system_id
      t.bigint :domain_id
      t.bigint :parent_id
      t.bigint :role_id

      t.string :email

      t.jsonb :spec, null: false, default: {}

      t.bigint :location_id
      t.string :source_ref
      t.string :managed_by, null: false, default: "user"
      t.datetime :synced_at

      t.timestamps null: false

      # Dropped once references have been remapped and verified.
      t.string :legacy_table
      t.bigint :legacy_id
      t.bigint :legacy_owner_id
      t.bigint :legacy_system_id
      t.bigint :legacy_domain_id
      t.bigint :legacy_parent_id
      t.bigint :legacy_role_id
    end

    add_index :junction_entities, %i[legacy_table legacy_id], unique: true,
              name: "index_junction_entities_on_legacy_row"
  end

  def create_relations_table
    create_table :junction_relations do |t|
      t.bigint :source_id, null: false
      t.bigint :target_id, null: false
      t.string :relation_type, null: false
      t.jsonb :metadata, null: false, default: {}
      t.bigint :location_id
      t.string :managed_by, null: false, default: "user"
      t.timestamps null: false
    end
  end

  def create_credentials_table
    create_table :junction_credentials do |t|
      t.bigint :entity_id, null: false
      t.string :password_digest, null: false
      t.timestamps null: false
    end

    add_index :junction_credentials, :entity_id, unique: true
    add_foreign_key :junction_credentials, :junction_entities,
                    column: :entity_id, on_delete: :cascade
  end

  # --- Row copying ----------------------------------------------------------

  def copy_apis
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, image_url, annotations,
         type, lifecycle, spec, legacy_table, legacy_id, legacy_owner_id,
         legacy_system_id, created_at, updated_at)
      SELECT 'Api', a.namespace, a.name, a.title, a.description, a.image_url,
             COALESCE(a.annotations, '{}'::jsonb), a.api_type, a.lifecycle,
             CASE WHEN a.definition IS NULL THEN '{}'::jsonb
                  ELSE jsonb_build_object('definition', a.definition) END,
             'junction_apis', a.id, a.owner_id, a.system_id,
             a.created_at, a.updated_at
      FROM junction_apis a
    SQL
  end

  def copy_components
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, image_url, annotations,
         type, lifecycle, spec, legacy_table, legacy_id, legacy_owner_id,
         legacy_system_id, created_at, updated_at)
      SELECT 'Component', c.namespace, c.name, c.title, c.description,
             c.image_url, COALESCE(c.annotations, '{}'::jsonb), c.component_type,
             c.lifecycle,
             CASE WHEN c.repository_url IS NULL THEN '{}'::jsonb
                  ELSE jsonb_build_object('repository_url', c.repository_url) END,
             'junction_components', c.id, c.owner_id, c.system_id,
             c.created_at, c.updated_at
      FROM junction_components c
    SQL
  end

  def copy_resources
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, image_url, annotations,
         type, legacy_table, legacy_id, legacy_owner_id, legacy_system_id,
         created_at, updated_at)
      SELECT 'Resource', r.namespace, r.name, r.title, r.description,
             r.image_url, COALESCE(r.annotations, '{}'::jsonb), r.resource_type,
             'junction_resources', r.id, r.owner_id, r.system_id,
             r.created_at, r.updated_at
      FROM junction_resources r
    SQL
  end

  def copy_systems
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, image_url, annotations,
         type, legacy_table, legacy_id, legacy_owner_id, legacy_domain_id,
         created_at, updated_at)
      SELECT 'System', s.namespace, s.name, s.title, s.description, s.image_url,
             COALESCE(s.annotations, '{}'::jsonb), s.system_type,
             'junction_systems', s.id, s.owner_id, s.domain_id,
             s.created_at, s.updated_at
      FROM junction_systems s
    SQL
  end

  def copy_domains
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, image_url, annotations,
         type, legacy_table, legacy_id, legacy_owner_id, legacy_parent_id,
         created_at, updated_at)
      SELECT 'Domain', d.namespace, d.name, d.title, d.description, d.image_url,
             COALESCE(d.annotations, '{}'::jsonb), d.domain_type,
             'junction_domains', d.id, d.owner_id, d.parent_id,
             d.created_at, d.updated_at
      FROM junction_domains d
    SQL
  end

  def copy_groups
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, image_url, annotations,
         type, email, legacy_table, legacy_id, legacy_parent_id, legacy_role_id,
         created_at, updated_at)
      SELECT 'Group', g.namespace, g.name, g.title, g.description, g.image_url,
             COALESCE(g.annotations, '{}'::jsonb), g.group_type, g.email,
             'junction_groups', g.id, g.parent_id, g.role_id,
             g.created_at, g.updated_at
      FROM junction_groups g
    SQL
  end

  # A user's address is copied to `email` as the public contact address, which
  # is what Backstage's `spec.profile.email` means for both users and groups.
  # The login identifier is a separate concern and moves to
  # junction_credentials.
  def copy_users
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, image_url, annotations, email, spec,
         legacy_table, legacy_id, created_at, updated_at)
      SELECT 'User', u.namespace, u.name, u.title, u.image_url,
             COALESCE(u.annotations, '{}'::jsonb), u.email_address,
             CASE WHEN u.pronouns IS NULL THEN '{}'::jsonb
                  ELSE jsonb_build_object('pronouns', u.pronouns) END,
             'junction_users', u.id, u.created_at, u.updated_at
      FROM junction_users u
    SQL
  end

  # The `system` boolean becomes `spec.system_role`. It cannot stay a column:
  # every entity row now has a `system` association, so a `system` attribute
  # would be ambiguous between the two.
  def copy_roles
    execute(<<~SQL.squish)
      INSERT INTO junction_entities
        (kind, namespace, name, title, description, spec, legacy_table,
         legacy_id, created_at, updated_at)
      SELECT 'Role', r.namespace, r.name, r.title, r.description,
             jsonb_build_object('system_role', r.system),
             'junction_roles', r.id, r.created_at, r.updated_at
      FROM junction_roles r
    SQL
  end

  # --- Reference remapping --------------------------------------------------

  def remap_entity_references
    REMAPPED_REFERENCES.each do |column, table|
      execute(<<~SQL.squish)
        UPDATE junction_entities e
        SET #{column} = target.id
        FROM junction_entities target
        WHERE e.legacy_#{column} IS NOT NULL
          AND target.legacy_table = '#{table}'
          AND target.legacy_id = e.legacy_#{column}
      SQL
    end

    # A parent always lives in the same source table as its child.
    execute(<<~SQL.squish)
      UPDATE junction_entities e
      SET parent_id = target.id
      FROM junction_entities target
      WHERE e.legacy_parent_id IS NOT NULL
        AND target.legacy_table = e.legacy_table
        AND target.legacy_id = e.legacy_parent_id
    SQL
  end

  def backfill_credentials
    execute(<<~SQL.squish)
      INSERT INTO junction_credentials
        (entity_id, password_digest, created_at, updated_at)
      SELECT e.id, u.password_digest, u.created_at, u.updated_at
      FROM junction_users u
      JOIN junction_entities e
        ON e.legacy_table = 'junction_users' AND e.legacy_id = u.id
    SQL
  end

  # Duplicate edges are collapsed: junction_dependencies has no uniqueness
  # constraint, and two identical edges mean the same thing. Self-edges are
  # skipped and reported rather than raised on, so a pre-existing data problem
  # does not block the migration.
  def backfill_relations
    report_skipped_self_edges

    execute(<<~SQL.squish)
      INSERT INTO junction_relations
        (source_id, target_id, relation_type, created_at, updated_at)
      SELECT DISTINCT ON (source.id, target.id)
             source.id, target.id, 'depends_on', d.created_at, d.updated_at
      FROM junction_dependencies d
      JOIN junction_entities source
        ON source.legacy_table = #{dependency_table_case('d.source_type')}
       AND source.legacy_id = d.source_id
      JOIN junction_entities target
        ON target.legacy_table = #{dependency_table_case('d.target_type')}
       AND target.legacy_id = d.target_id
      WHERE source.id <> target.id
      ORDER BY source.id, target.id, d.created_at
    SQL
  end

  def remap_external_references
    remap_external("junction_group_memberships", "group_id", "junction_groups")
    remap_external("junction_group_memberships", "user_id", "junction_users")
    remap_external("junction_sessions", "user_id", "junction_users")
    remap_external("junction_identities", "user_id", "junction_users")
    remap_external("junction_role_permissions", "role_id", "junction_roles")
  end

  def remap_external(table, column, legacy_table)
    remove_foreign_key table, column: column
    execute(<<~SQL.squish)
      UPDATE #{table} t
      SET #{column} = e.id
      FROM junction_entities e
      WHERE e.legacy_table = '#{legacy_table}' AND e.legacy_id = t.#{column}
    SQL
  end

  # --- Verification ---------------------------------------------------------

  def verify_counts!(before)
    after = select_all("SELECT kind, COUNT(*) AS total FROM junction_entities GROUP BY kind")
            .to_a.to_h { |row| [ row["kind"], row["total"].to_i ] }

    mismatches = SOURCE_TABLES.filter_map do |table, kind|
      expected = before.fetch(table)
      actual = after.fetch(kind, 0)
      "#{table} -> #{kind}: expected #{expected}, copied #{actual}" if expected != actual
    end

    return if mismatches.empty?

    raise ActiveRecord::MigrationError,
          "Row counts do not match after copying:\n  #{mismatches.join("\n  ")}"
  end

  def verify_no_dangling_references!
    columns = REMAPPED_REFERENCES.keys + [ "parent_id" ]

    dangling = columns.filter_map do |column|
      count = count_rows(
        "junction_entities",
        "legacy_#{column} IS NOT NULL AND #{column} IS NULL"
      )
      "#{column}: #{count} row(s) could not be remapped" if count.positive?
    end

    credentials = count_rows("junction_entities", "kind = 'User'") -
                  count_rows("junction_credentials")
    dangling << "#{credentials} user(s) without credentials" unless credentials.zero?

    return if dangling.empty?

    raise ActiveRecord::MigrationError,
          "Dangling references after remapping:\n  #{dangling.join("\n  ")}"
  end

  def report_skipped_self_edges
    count = select_value(<<~SQL.squish).to_i
      SELECT COUNT(*) FROM junction_dependencies d
      WHERE d.source_type = d.target_type AND d.source_id = d.target_id
    SQL
    return if count.zero?

    say "Skipping #{count} self-referential dependency row(s); they cannot be " \
        "represented in junction_relations."
  end

  # --- Constraints ----------------------------------------------------------

  def finalize_entities_table
    %w[
      legacy_table legacy_id legacy_owner_id legacy_system_id legacy_domain_id
      legacy_parent_id legacy_role_id
    ].each { |column| remove_column :junction_entities, column }

    # Unconditional, so Rails can skip the redundant uniqueness SELECT when
    # validating a record (see ActiveRecord's covered_by_unique_index?).
    add_index :junction_entities, %i[kind namespace name], unique: true,
              name: "index_junction_entities_on_kind_and_slug"
    add_index :junction_entities, %i[kind type]
    add_index :junction_entities, %i[kind lifecycle]
    add_index :junction_entities, %i[kind updated_at]
    add_index :junction_entities, :tags, using: :gin
    add_index :junction_entities, :labels, using: :gin, opclass: :jsonb_path_ops
    add_index :junction_entities, "((spec->>'target'))", unique: true,
              where: "kind = 'Location'",
              name: "index_junction_entities_on_location_target"

    # A user's address is their login identifier, so it stays unique. Groups
    # carry a contact address too, hence the partial index.
    add_index :junction_entities, :email, unique: true, where: "kind = 'User'",
              name: "index_junction_entities_on_user_email"

    %i[owner_id system_id domain_id parent_id role_id location_id].each do |column|
      add_index :junction_entities, column
      add_foreign_key :junction_entities, :junction_entities, column: column
    end

    add_check_constraint :junction_entities,
                         "managed_by IN ('user', 'location', 'plugin')",
                         name: "junction_entities_managed_by_values"
  end

  def finalize_relations_table
    add_index :junction_relations, %i[source_id relation_type target_id],
              unique: true, name: "index_junction_relations_on_edge"
    add_index :junction_relations, %i[target_id relation_type source_id],
              name: "index_junction_relations_on_reverse_edge"
    add_index :junction_relations, :location_id

    add_foreign_key :junction_relations, :junction_entities,
                    column: :source_id, on_delete: :cascade
    add_foreign_key :junction_relations, :junction_entities,
                    column: :target_id, on_delete: :cascade
    add_foreign_key :junction_relations, :junction_entities,
                    column: :location_id, on_delete: :nullify

    add_check_constraint :junction_relations, "source_id <> target_id",
                         name: "junction_relations_no_self_edge"
  end

  def finalize_external_references
    add_foreign_key :junction_group_memberships, :junction_entities, column: :group_id
    add_foreign_key :junction_group_memberships, :junction_entities, column: :user_id
    add_foreign_key :junction_sessions, :junction_entities, column: :user_id
    add_foreign_key :junction_identities, :junction_entities, column: :user_id
    add_foreign_key :junction_role_permissions, :junction_entities, column: :role_id
  end

  # --- Helpers --------------------------------------------------------------

  def dependency_table_case(column)
    whens = DEPENDENCY_TABLES.map { |type, table| "WHEN '#{type}' THEN '#{table}'" }
    "(CASE #{column} #{whens.join(" ")} END)"
  end

  def count_rows(table, condition = nil)
    sql = "SELECT COUNT(*) FROM #{table}"
    sql += " WHERE #{condition}" if condition
    select_value(sql).to_i
  end
end
