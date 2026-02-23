# frozen_string_literal: true

module Junction
  # Value object representing a single permission in the RBAC system.
  #
  # Permissions are stored as strings, in the format:
  # `domain/context.ownership.access`
  #
  # For example: `junction.codes/components.all.read`
  class Permission
    PERMISSION_REGEXP = /\A([^\/]+)\/([^.]+)\.([^.]+)\.([^.]+)\z/.freeze

    # Enumeration of supported access levels.
    module Access
      READ = "read"
      WRITE = "write"
      DESTROY = "destroy"
      ALL = [ READ, WRITE, DESTROY ].freeze
    end

    # Enumeration of supported ownership scopes.
    module Ownership
      ALL = "all"
      OWNED = "owned"
      ALL = [ ALL, OWNED ].freeze
    end

    attr_reader :domain, :context, :ownership, :access, :description

    # Initializes a new permission.
    #
    # @param domain [String] Domain the permission belongs to.
    # @param context [String] Context within the domain.
    # @param ownership [String] Ownership scope of the permission.
    # @param access [String] Access level granted by the permission.
    # @param description [String] Human-readable description of the permission.
    def initialize(domain:, context:, ownership:, access:, description: "")
      @domain = domain
      @context = context
      @ownership = ownership
      @access = access
      @description = description
    end

    # Parse a permission string into a Permission object.
    #
    # Expects format: domain/context.ownership.access
    #
    # @param str [String] Permission string to parse.
    # @return [Junction::Permission, nil] Parsed permission or nil if invalid
    def self.parse(str)
      return nil unless str.is_a?(String)

      match = str.match(PERMISSION_REGEXP)
      return nil unless match

      domain, context, ownership, access = match.captures

      new(domain:, context:, ownership:, access:)
    end

    # Full permission string for storage.
    #
    # @return [String] Permission string.
    def to_s
      "#{domain}/#{context}.#{ownership}.#{access}"
    end
    alias_method :id, :to_s

    # Whether the permission grants read access.
    #
    # @return [Boolean] Whether the permission grants read access.
    def read?
      access == Access::READ
    end

    # Whether the permission grants write access.
    #
    # @return [Boolean] Whether the permission grants write access.
    def write?
      access == Access::WRITE
    end

    # Whether the permission grants destroy access.
    #
    # @return [Boolean] Whether the permission grants destroy access.
    def destroy?
      access == Access::DESTROY
    end

    # Whether the permission grants access to owned resources.
    #
    # @return [Boolean] Whether the permission grants access to owned resources.
    def owned?
      ownership == Ownership::OWNED
    end

    # Whether the permission grants access to all resources.
    #
    # @return [Boolean] Whether the permission grants access to all resources.
    def all?
      ownership == Ownership::ALL
    end

    # Compare two permissions for equality.
    #
    # @param other [Permission] The other permission to compare to.
    # @return [Boolean] Whether the two permissions are equal.
    def ==(other)
      other.is_a?(Permission) && to_s == other.to_s
    end
    alias_method :eql?, :==

    # Generate a hash for the permission.
    #
    # @return [Integer] The hash of the permission.
    def hash
      to_s.hash
    end
  end
end
