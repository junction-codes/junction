# frozen_string_literal: true

# Every entity kind shares the junction_entities table, so fixture sets that
# touch it have to be loaded together.
#
# Rails deletes each table a fixture set covers before inserting, and it caches
# loaded fixtures per example group. A group declaring only some of these files
# would therefore wipe the rows belonging to the others, while rows in tables it
# does not cover, junction_group_memberships in particular, survive and are left
# pointing at entities that no longer exist.
#
# Declaring the whole set everywhere keeps the loaded data identical between
# groups, so nothing is wiped and no reference is left dangling.
ENTITY_FIXTURE_SETS = %w[
  junction/users
  junction/credentials
  junction/roles
  junction/groups
  junction/group_memberships
  junction/group_roles
  junction/domains
  junction/systems
  junction/components
].freeze
