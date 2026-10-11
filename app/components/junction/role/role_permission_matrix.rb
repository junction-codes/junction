# frozen_string_literal: true

module Junction
  module Components
    module Role
      # Renders what a role may do, as one row per domain and context.
      #
      # A permission combines a domain, a context, an access level and an
      # ownership scope. As a list of strings a reader has to parse all four
      # at once; as a grid, "what can this role destroy" is a column.
      class RolePermissionMatrix < Base
        # The access levels, in the order they escalate.
        ACCESS = Junction::Permission::Access::VALUES

        # Initializes the component.
        #
        # @param rows [Array<Hash>] `{ context:, read:, write:, destroy: }`,
        #   where each access holds an ownership scope or nil.
        # @option rows [String] :context The context for the row.
        # @option rows [String] :read The ownership scope for read access.
        # @option rows [String] :write The ownership scope for write access.
        # @option rows [String] :destroy The ownership scope for destroy access.
        # @param user_attrs [Hash] Additional HTML attributes.
        def initialize(rows:, **user_attrs)
          @rows = rows

          super(**user_attrs)
        end

        def view_template
          Table(**attrs) do |table|
            table.header do |header|
              header.row do |row|
                row.head { t(".context") }
                ACCESS.each { |access| row.head(class: "w-[120px]") { t(".#{access}") } }
              end
            end

            table.body do |body|
              @rows.each { |row| context_row(body, row) }
            end
          end

          legend
        end

        # Renders the key to the two kinds of blank cell.
        #
        # Each mark is painted as its cells paint it, so the legend and the
        # table can be matched by eye.
        def legend
          div(class: "mt-3 flex flex-wrap items-center gap-x-5 gap-y-1 " \
                     "text-[11.5px] text-text-tertiary") do
            legend_item("—", t(".not_granted"))
            legend_item("·", t(".not_registered"), faded: true)
          end
        end

        # Renders one entry in the legend.
        #
        # @param glyph [String] The mark as the table draws it.
        # @param label [String] Label for the mark.
        # @param faded [Boolean] Whether the mark should be displayed in a faded
        #   style.
        def legend_item(glyph, label, faded: false)
          span(class: "inline-flex items-baseline gap-1.5") do
            span(class: faded ? "text-text-tertiary/40" : nil,
                 aria_hidden: "true") { glyph }
            plain label
          end
        end

        private

        # Renders a single context row.
        #
        # @param body [Table::TableBody] The table's body.
        # @param row [Hash] The context and its access levels.
        def context_row(body, row)
          body.row do |cells|
            cells.cell(class: "font-mono text-xs") { row.fetch(:context) }

            ACCESS.each do |access|
              cells.cell { ownership(row[access.to_sym]) }
            end
          end
        end

        # Renders the ownership scope or its absence for a permission.
        #
        # The scope is written out rather than ticked, because "all" and
        # "owned" are different answers and a tick could only say that one of
        # them applies. The two kinds of blank are drawn differently for the
        # same reason.
        #
        # @param scope [String, Symbol] The ownership scope, or a marker.
        def ownership(scope)
          case scope
          when Junction::Roles::Overview::NOT_REGISTERED then unregistered
          when Junction::Roles::Overview::NOT_GRANTED, nil then not_granted
          else granted(scope)
          end
        end

        # Renders the scope the role holds at this access level.
        #
        # @param scope [String] The ownership scope.
        def granted(scope)
          span(class: "inline-flex items-center rounded-md border px-2 py-0.5 " \
                      "text-[11.5px] font-medium #{scope_classes(scope)}") do
            t(".#{scope}")
          end
        end

        # Renders the mark for a permission the role doesn't hold.
        def not_granted
          span(class: "text-text-tertiary") do
            span(aria_hidden: "true") { "—" }
            span(class: "sr-only") { t(".not_granted") }
          end
        end

        # Renders the mark for a permission that doesn't exist.
        def unregistered
          span(class: "text-text-tertiary/40") do
            span(aria_hidden: "true") { "·" }
            span(class: "sr-only") { t(".not_registered") }
          end
        end

        # Returns the classes for a scope.
        #
        # "all" is tinted and "owned" isn't, because everything is a wider grant
        # than what a group owns.
        #
        # @param scope [String] The ownership scope.
        # @return [String] Its classes.
        def scope_classes(scope)
          if scope == Junction::Permission::Ownership::ALL
            "border-accent-soft-border bg-accent-subtle text-accent-strong"
          else
            "border-border bg-background text-text-body"
          end
        end
      end
    end
  end
end
