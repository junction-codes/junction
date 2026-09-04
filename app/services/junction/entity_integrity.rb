# frozen_string_literal: true

module Junction
  # Checks the referential rules that the database cannot express.
  #
  # Every kind shares the same table, so a foreign key can only assert
  # that a reference points at *an* entity, not at one of the right kind. An
  # owner column pointing at a component, or a session pointing at a group, is
  # a valid row as far as Postgres is concerned.
  #
  # These checks close that gap. They are the counterpart to the model
  # validations: the validations stop bad data being written through the app,
  # and this catches anything written around it; such as a migration, a seed
  # importer, a plugin, or hand-edited SQL.
  class EntityIntegrity
    Check = Struct.new(:id, :description, :relation, keyword_init: true)
    Problem = Struct.new(:check, :count, :sample_ids, keyword_init: true) do
      # @return [String] One line naming the problem and some offending rows.
      def to_s
        "#{check.description}: #{count} row(s), e.g. #{sample_ids.join(', ')}"
      end
    end

    # Number of offending IDs reported per problem.
    SAMPLE_SIZE = 5

    class << self
      # Entities whose reference points at an entity of an unexpected kind.
      #
      # @param column [Symbol] The reference column.
      # @param kinds [Array<String>] Kinds the reference may point at.
      # @return [ActiveRecord::Relation] The offending entities.
      def references(column, kinds)
        Entity.where.not(column => nil)
              .where.not(column => Entity.where(kind: kinds).select(:id))
      end

      # Entities whose parent is a different kind from themselves.
      #
      # Domains and groups share one `parent_id`, so a cross-kind parent is
      # representable. The association is kind-scoped and would quietly resolve
      # to nil, hiding it.
      #
      # @return [ActiveRecord::Relation] The offending entities.
      def mismatched_parents
        Entity.joins(
          "JOIN junction_entities parents ON parents.id = junction_entities.parent_id"
        ).where("parents.kind <> junction_entities.kind")
      end

      # Relations whose source or target is a kind that cannot participate.
      #
      # @return [ActiveRecord::Relation] The offending relations.
      def undependable_relations
        dependable = Entity.where(kind: Junction::Kinds.dependable_names).select(:id)

        Relation.where.not(source_id: dependable)
                .or(Relation.where.not(target_id: dependable))
      end
    end

    # Every check, with the relation selecting the rows that fail it.
    #
    # Relations are built when a check runs rather than when this is defined,
    # so the constant does not force models to load at boot.
    CHECKS = [
      Check.new(
        id: :unregistered_kind,
        description: "entities with a kind no longer registered",
        relation: -> { Entity.where.not(kind: Junction::Kinds.names) }
      ),
      Check.new(
        id: :owner_kind,
        description: "entities owned by something other than a group or user",
        relation: -> { references(:owner_id, Ownable::OWNER_KINDS) }
      ),
      Check.new(
        id: :system_kind,
        description: "entities whose system is not a System",
        relation: -> { references(:system_id, %w[System]) }
      ),
      Check.new(
        id: :domain_kind,
        description: "entities whose domain is not a Domain",
        relation: -> { references(:domain_id, %w[Domain]) }
      ),
      Check.new(
        id: :group_role_group,
        description: "role grants held by something other than a group",
        relation: -> { GroupRole.where.not(group_id: Group.select(:id)) }
      ),
      Check.new(
        id: :group_role_role,
        description: "role grants naming something that is not a Role",
        relation: -> { GroupRole.where.not(role_id: Role.select(:id)) }
      ),
      Check.new(
        id: :parent_kind,
        description: "entities whose parent is a different kind",
        relation: -> { mismatched_parents }
      ),
      Check.new(
        id: :relation_target_kind,
        description: "relations pointing at a kind that cannot be depended on",
        relation: -> { undependable_relations }
      ),
      Check.new(
        id: :session_owner,
        description: "sessions belonging to something other than a user",
        relation: -> { Session.where.not(user_id: User.select(:id)) }
      ),
      Check.new(
        id: :identity_owner,
        description: "identities belonging to something other than a user",
        relation: -> { Identity.where.not(user_id: User.select(:id)) }
      ),
      Check.new(
        id: :membership_user,
        description: "group memberships whose user is not a user",
        relation: -> { GroupMembership.where.not(user_id: User.select(:id)) }
      ),
      Check.new(
        id: :membership_group,
        description: "group memberships whose group is not a group",
        relation: -> { GroupMembership.where.not(group_id: Group.select(:id)) }
      ),
      Check.new(
        id: :role_permission_role,
        description: "role permissions whose role is not a Role",
        relation: -> { RolePermission.where.not(role_id: Role.select(:id)) }
      ),
      Check.new(
        id: :credential_owner,
        description: "credentials belonging to something other than a user",
        relation: -> { Credential.where.not(entity_id: User.select(:id)) }
      ),
      Check.new(
        id: :missing_credential,
        description: "users without a credential",
        relation: -> { User.where.missing(:credential) }
      )
    ].freeze

    # Runs every check.
    #
    # @return [Array<Problem>] The problems found, empty when the data is
    #   sound.
    def self.call
      new.call
    end

    # Runs every check.
    #
    # @return [Array<Problem>] The problems found.
    def call
      CHECKS.filter_map { |check| problem_for(check) }
    end

    private

    # Runs a single check.
    #
    # @param check [Check] The check to run.
    # @return [Problem, nil] The problem, or nil when the check passes.
    def problem_for(check)
      relation = self.class.instance_exec(&check.relation)
      ids = relation.limit(SAMPLE_SIZE).pluck(:id)
      return if ids.empty?

      Problem.new(check:, count: relation.count, sample_ids: ids)
    end
  end
end
