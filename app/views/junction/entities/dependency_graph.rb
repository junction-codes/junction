# frozen_string_literal: true

module Junction
  module Views
    module Entities
      # Renders the entity's dependents and dependencies as a graph.
      #
      # The nodes are links carrying the same kind chip used elsewhere, and the
      # edges are empty paths. The browser works out where they go, keeping the
      # design system out of JavaScript and making the nodes reachable from the
      # keyboard.
      class DependencyGraph < Views::Base
        include Junction::EntityCopy

        # Initializes the view.
        #
        # @param entity [Junction::Entity] The entity the graph is drawn around.
        # @param graph [Hash] The nodes, edges and counts from
        #   {Junction::DependencyGraphService}.
        def initialize(entity:, graph:)
          @entity = entity
          @graph = graph
        end

        def view_template
          turbo_frame_tag "dependency_graph" do
            if nodes.one?
              empty_state
            else
              div(**graph_attrs) do
                canvas
                footer
              end
            end
          end
        end

        private

        attr_reader :graph

        # The nodes, as the service collected them.
        #
        # @return [Array<Hash>] The nodes.
        def nodes
          graph.fetch(:nodes)
        end

        def graph_attrs
          {
            data: {
              controller: "graph",
              graph_edges_value: graph.fetch(:edges).to_json
            }
          }
        end

        # Renders the box the graph is laid out in.
        def canvas
          div(class: "relative h-[420px] overflow-hidden rounded-xl border " \
                     "border-border bg-inset",
              data: { graph_target: "canvas" }) do
            edges
            div(class: "absolute inset-0", data: { graph_target: "nodes" }) do
              nodes.each { |node| node_link(node) }
            end
          end
        end

        # Renders a path per edge, for the layout to put a shape into.
        def edges
          svg(class: "absolute inset-0 h-full w-full overflow-visible",
              aria_hidden: "true", data: { graph_target: "edges" }) do |s|
            graph.fetch(:edges).each do |edge|
              s.path(fill: "none", stroke_width: "1.5",
                     class: edge_classes(edge),
                     data: { source: edge[:source], target: edge[:target] })
            end
          end
        end

        # The classes drawing one edge.
        #
        # Belonging to a system is not depending on it, so the two are drawn
        # differently.
        #
        # @param edge [Hash] The edge.
        # @return [String] The classes.
        def edge_classes(edge)
          return "stroke-accent-muted [stroke-dasharray:4_4]" if
            edge[:type] == Junction::Relation::PART_OF

          "stroke-line-strong"
        end

        # Renders one node.
        #
        # If the current user doesn't have permission to view the entity, the
        # label is rendered as plain text without a link. This relationship is
        # important to the current entity, and therefore to the user's
        # understanding of it.
        #
        # @param node [Hash] The node.
        def node_link(node)
          entity = node.fetch(:record)
          attrs = { class: node_classes(node),
                    data: { graph_target: "node", id: node.fetch(:id),
                            aside: node.fetch(:aside).to_s } }

          if allowed_to?(:show?, entity)
            a(href: junction_catalog_path(entity), **attrs) { node_body(entity) }
          else
            div(**attrs) { node_body(entity) }
          end
        end

        # Renders the body of a node.
        #
        # @param entity [Junction::Entity] The entity.
        def node_body(entity)
          KindChip(entity:, size: :xs, ring: true, class: "shrink-0")
          span(class: "truncate font-mono text-[12px]") { entity.name }
        end

        # The classes drawing one node.
        #
        # @param node [Hash] The node.
        # @return [String] The classes.
        def node_classes(node)
          focused = node.fetch(:id) == graph.fetch(:current_node_id)

          [
            "absolute left-0 top-0 inline-flex max-w-[190px] items-center gap-2",
            "rounded-[10px] border bg-surface px-3 py-2 shadow-sm",
            "transition-shadow hover:shadow-md focus-visible:outline-none",
            "focus-visible:ring-2 focus-visible:ring-ring",
            focused ? "border-accent-solid ring-1 ring-accent-solid" : "border-border"
          ].join(" ")
        end

        # Renders the legend and what didn't fit in the graph.
        def footer
          div(class: "mt-3 flex flex-wrap items-center gap-x-5 gap-y-2 " \
                     "text-[11.5px] text-text-tertiary") do
            kinds_drawn.each { |kind| legend_kind(kind) }
            legend_line("bg-line-strong", t(".graph_depends_on"))
            legend_line("bg-accent-muted", t(".graph_part_of"))
            beyond_note
          end
        end

        # Renders the legend for a single kind.
        #
        # @param kind [String] The kind, as the model names it.
        def legend_kind(kind)
          swatch = [
            Components::KindChip::TINTS.fetch(kind, Components::KindChip::NEUTRAL),
            Components::KindChip::RINGS.fetch(kind, Components::KindChip::NEUTRAL_RING)
          ].join(" ")

          span(class: "flex items-center gap-1.5") do
            span(class: "h-3 w-3 rounded-[4px] #{swatch}")
            plain Junction::Kinds.model_for(kind).model_name.human
          end
        end

        # The kinds the graph drew, in the order the design lists them.
        #
        # @return [Array<String>] The kinds.
        def kinds_drawn
          order = Components::KindChip::TINTS.keys

          nodes.map { |node| node.fetch(:record).kind }.uniq.sort_by do |kind|
            order.index(kind) || order.size
          end
        end

        # Renders one line style and what it means.
        #
        # @param swatch [String] The class painting the line.
        # @param label [String] What the line means.
        def legend_line(swatch, label)
          span(class: "flex items-center gap-1.5") do
            span(class: "h-px w-5 #{swatch}")
            plain label
          end
        end

        # Renders how much of the neighborhood is missing.
        #
        # The walk stops a set number of steps out, so a busy entity has
        # neighbors past the edge of the picture.
        def beyond_note
          beyond = graph.fetch(:beyond)
          return if beyond.zero?

          span { t(".graph_beyond", count: beyond, depth: graph.fetch(:depth)) }
        end

        # Renders the line shown when the entity stands alone.
        def empty_state
          div(class: "flex h-[420px] flex-col items-center justify-center " \
                     "gap-1 rounded-xl border border-border bg-inset px-6 " \
                     "text-center") do
            p(class: "text-[13px] text-text-body") { t(".graph_empty") }
            p(class: "text-[12px] text-text-tertiary") { t(".graph_empty_hint") }
          end
        end

        # Names the kind for the shared copy.
        #
        # @return [Class] The entity's class.
        def copy_model
          @entity.class
        end
      end
    end
  end
end
