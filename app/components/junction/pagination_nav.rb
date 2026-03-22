# frozen_string_literal: true

module Junction
  module Components
    # Pagination navigation component driven by Pagy metadata.
    #
    # Renders a full set of page controls: first, previous, page number links
    # (with an optional ellipsis and trailing pages), next, and last. Also
    # renders a per-page selector when +per_page_url+ is provided.
    #
    #
    # @example
    #   PaginationNav(
    #     pagy: @pagy,
    #     page_url: ->(page) { domains_path(q: @query_params, page:, per_page: @per_page) },
    #     per_page_url: ->(per_page) { domains_path(q: @query_params, per_page:) }
    #   )
    class PaginationNav < Base
      # Number of leading pages always anchored at the start.
      HEAD_SIZE = 2

      # Number of trailing pages always anchored at the end.
      TAIL_SIZE = 2

      # Number of page links on each side of the current page.
      WINDOW_HALF = 1

      # Maximum number of pages before the list of pages becomes gapped.
      UNGAPPED_MAX_PAGES = HEAD_SIZE + WINDOW_HALF * 2 + TAIL_SIZE + 1

      # Initializes a new component.
      #
      # @param pagy [Pagy] Pagy metadata object from the controller.
      # @param page_url [#call] Callable that accepts a page number and returns
      #   a URL string preserving current filters, sort, and per_page.
      # @param per_page_url [#call, nil] Callable that accepts a per_page
      #   integer and returns a URL string. When provided, renders the per-page
      #   selector.
      # @param turbo_action [String] Turbo action to use for pagination links.
      # @param user_attrs [Hash] Additional HTML attributes for the component.
      def initialize(pagy:, page_url:, per_page_url: nil,
                     turbo_action: "advance", **user_attrs)
        @pagy = pagy
        @page_url = page_url
        @per_page_url = per_page_url
        @turbo_action = turbo_action

        super(**user_attrs)
      end

      def view_template
        return unless @pagy.pages > 1 || @per_page_url

        div(class: "mt-4 flex flex-col gap-2") do
          PerPageSelector(
            per_page_url: @per_page_url,
            current: @pagy.options[:limit],
            total: @pagy.count,
            turbo_action:,
          ) if @per_page_url

          render_page_controls if @pagy.pages > 1
        end
      end

      private

      attr_reader :turbo_action

      # Renders the pagination controls.
      def render_page_controls
        Pagination do |nav|
          nav.content do |c|
            c.first(href: @page_url.call(1), active: @pagy.page == 1, turbo_action:)
            c.previous(href: @page_url.call(@pagy.previous), active: !@pagy.previous, turbo_action:)

            render_page_links(c)

            c.next(href: @page_url.call(@pagy.next), active: !@pagy.next, turbo_action:)
            c.last(href: @page_url.call(@pagy.pages), active: @pagy.page == @pagy.pages, turbo_action:)
          end
        end
      end

      # Renders the page links for each page in the navigation.
      #
      # @param content [PaginationContent] The content component the links are
      #   rendered in.
      def render_page_links(content)
        page_series(@pagy.page, @pagy.pages).each do |entry|
          if entry == :gap
            content.ellipsis
          else
            content.item(
              href: @page_url.call(entry),
              active: entry == @pagy.page,
              turbo_action:
            ) { entry.to_s }
          end
        end
      end

      # Returns an ordered list of page numbers and `:gap` to render.
      #
      # Two modes based on proximity to the end:
      #
      # Normal (floating window): Window of `WINDOW_HALF * 2 + 1` pages centered
      # around the current page, with an anchored tail of `TAIL_SIZE` pages. The
      # window's right edge is clamped so it never overlaps the tail; meaning
      # two different pages can produce the same window when near the boundary.
      #
      # End mode (when window can no longer fit before tail): Switch to showing
      # `HEAD_SIZE` anchor pages at the start, `:gap`, and a tail of
      # `WINDOW_HALF * 2 + 1` pages.
      #
      # Examples (HEAD_SIZE=2, WINDOW_HALF=1, TAIL_SIZE=2, total=11):
      #   current=1  → [1, 2, 3, :gap, 10, 11]
      #   current=6  → [5, 6, 7, :gap, 10, 11]
      #   current=7  → [6, 7, 8, :gap, 10, 11]
      #   current=8  → [6, 7, 8, :gap, 10, 11] (window clamped, same as 7)
      #   current=9  → [1, 2, :gap, 9, 10, 11] (end mode)
      #   current=11 → [1, 2, :gap, 9, 10, 11] (end mode)
      #
      # @param current [Integer] Current page number.
      # @param total [Integer] Total number of pages.
      # @return [Array<Integer, Symbol>] Ordered list of page items to be
      #   rendered.
      def page_series(current, total)
        return (1..total).to_a if total <= UNGAPPED_MAX_PAGES

        right_clamp = total - TAIL_SIZE - WINDOW_HALF
        if current > right_clamp
          [ *1..HEAD_SIZE, :gap, *(right_clamp + 1)..total ]
        else
          right = [ current + WINDOW_HALF, right_clamp ].min
          left  = [ right - 2 * WINDOW_HALF, 1 ].max
          right = [ left  + 2 * WINDOW_HALF, right_clamp ].min

          [ *(left..right), :gap, *(total - TAIL_SIZE + 1)..total ]
        end
      end
    end
  end
end
