# frozen_string_literal: true

module Junction
  # Checks the referential rules that the database cannot express.
  #
  # Every kind shares `junction_entities`, so a foreign key can only assert
  # that a reference points at *an* entity, not at one of the right kind. An
  # owner column pointing at a component, or a session pointing at a group, is
  # a valid row as far as Postgres is concerned.
  #
  # These checks close that gap. They are the counterpart to the model
  # validations: the validations stop bad data being written through the app,
  # and this catches anything written around it -- a migration, a seed
  # importer, a plugin, or hand-edited SQL.
  class EntityIntegrity
    # A failed check and the rows that failed it.
    Problem = Struct.new(:description, :count, :sample_ids, keyword_init: true) do
      # @return [String] One line naming the problem and some offending rows.
      def to_s
        "#{description}: #{count} row(s), e.g. #{sample_ids.join(', ')}"
      end
    end

    # Number of offending IDs reported per problem.
    SAMPLE_SIZE = 5

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
      checks.filter_map do |description, relation|
        ids = relation.limit(SAMPLE_SIZE).pluck(:id)
        next if ids.empty?

        Problem.new(description:, count: relation.count, sample_ids: ids)
      end
    end

    private

    # Each check, as a description and a relation selecting offending rows.
    #
    # @return [Hash{String => ActiveRecord::Relation}] The checks.
    def checks
      {
        "entities with a kind no longer registered" =>
          Entity.where.not(kind: Junction::Kinds.names),
        "entities owned by something other than a group or user" =>
          references(:owner_id, Ownable::OWNER_KINDS),
        "entities whose system is not a System" =>
          references(:system_id, %w[System]),
        "entities whose domain is not a Domain" =>
          references(:domain_id, %w[Domain]),
        "entities whose role is not a Role" =>
          references(:role_id, %w[Role]),
        "entities holding a role that are not groups" =>
          Entity.where.not(role_id: nil).where.not(kind: "Group"),
        "entities whose parent is a different kind" =>
          mismatched_parents,
        "relations pointing at a kind that cannot be depended on" =>
          undependable_relations,
        "sessions belonging to something other than a user" =>
          Session.where.not(user_id: User.select(:id)),
        "identities belonging to something other than a user" =>
          Identity.where.not(user_id: User.select(:id)),
        "group memberships whose user is not a user" =>
          GroupMembership.where.not(user_id: User.select(:id)),
        "group memberships whose group is not a group" =>
          GroupMembership.where.not(group_id: Group.select(:id)),
        "role permissions whose role is not a Role" =>
          RolePermission.where.not(role_id: Role.select(:id)),
        "credentials belonging to something other than a user" =>
          Credential.where.not(entity_id: User.select(:id)),
        "users without a credential" =>
          User.where.missing(:credential)
      }
    end

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

      Relation.where.not(source_id: dependable).or(
        Relation.where.not(target_id: dependable)
      )
    end
  end
end
