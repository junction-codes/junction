# frozen_string_literal: true

require "action_policy"

module Junction
  # The entities a user is allowed to read, per kind.
  #
  # Read scoping is authorization, so it lives in one place and every caller
  # uses the same object. A listing and the count beside it in the rail have to
  # agree, or the count discloses how many entities exist to someone who cannot
  # list them.
  #
  # The user is an argument rather than something read from the surrounding
  # request, so this can be used outside a controller and tested without one.
  # {.current} is the request-scoped instance for callers that just want
  # "whoever is signed in."
  class ReadableEntities
    include ::ActionPolicy::Behaviour

    authorize :user, through: :user

    attr_reader :user

    # The instance for the current request.
    #
    # Held on {Junction::Current}, so the counts behind the rail are computed
    # once per request no matter how many things ask for them, and are dropped
    # when the request ends.
    #
    # @return [ReadableEntities] The request-scoped instance.
    def self.current
      memo = Junction::Current.readable_entities
      return memo if memo && memo.user == Junction::Current.user

      Junction::Current.readable_entities = new
    end

    # Initializes a new instance.
    #
    # @param user [Junction::User, nil] The user to scope for. A nil user is
    #   granted nothing, which is what an unauthenticated request should see.
    def initialize(user: Junction::Current.user)
      @user = user
      @counts = {}
    end

    # Relation for one kind, restricted to what the user may read.
    #
    # @param model [Class] The kind's model class.
    # @return [ActiveRecord::Relation, nil] The relation, or nil when the user
    #   may read neither all nor owned.
    def scope_for(model)
      return model.all if allowed_to?(:index_all?, model)

      model.where(owner_id: user.owner_ids) if allowed_to?(:index_owned?, model)
    end

    # Relation spanning several kinds, honouring each kind's permissions.
    #
    # Every kind shares a table, so this is one query rather than one per model
    # merged in Ruby. The relation is still composed per kind, because
    # permissions differ per kind and querying `Entity` directly would also
    # leak users and groups into catalog listings.
    #
    # @param kinds [Array<Junction::Kind>] The kinds to include.
    # @return [ActiveRecord::Relation] The relation.
    def scope_across(kinds)
      kinds.filter_map { |kind| kind_scope(kind) }.reduce(:or) || Entity.none
    end

    # How many readable entities there are of each kind.
    #
    # Memoized per set of kinds. The rail asks on every page, and the answer
    # cannot change within a single request.
    #
    # @param kinds [Array<Junction::Kind>] The kinds to count.
    # @return [Hash{String => Integer}] Counts keyed by kind name. A kind the
    #   user cannot read is absent rather than zero.
    def counts(kinds)
      @counts[kinds.map(&:name)] ||= scope_across(kinds).group(:kind).count
    end

    private

    # Relation for one kind within a cross-kind query.
    #
    # @param kind [Junction::Kind] The kind.
    # @return [ActiveRecord::Relation, nil] The relation, or nil when
    #   unreadable.
    def kind_scope(kind)
      model = kind.model
      return Entity.where(kind: kind.name) if allowed_to?(:index_all?, model)

      Entity.where(kind: kind.name, owner_id: user.owner_ids) if allowed_to?(:index_owned?, model)
    end
  end
end
