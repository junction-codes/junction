# frozen_string_literal: true

module Junction
  module Components
    module Breadcrumb
      # Renders a full breadcrumb trail from an array of items.
      class Trail < Base
        # Initializes a new component.
        #
        # @param items [Array<Hash>] List of items to include in the breadcrumb
        #   trail. Each hash has :label (String) and optionally :href (String).
        #   The last item is treated as the current page and rendered without a
        #   link.
        # @param user_attrs [Hash] Additional HTML attributes for the component.
        def initialize(items:, **user_attrs)
          @items = items

          super(**user_attrs)
        end

        def view_template
          render Breadcrumb.new do
            render BreadcrumbList.new do
              @items.each_with_index do |item, index|
                last = index == @items.length - 1

                render BreadcrumbItem.new do
                  if last
                    render Page.new { item[:label] }
                  else
                    render BreadcrumbLink.new(href: item[:href]) { item[:label] }
                  end
                end

                render BreadcrumbSeparator.new unless last
              end
            end
          end
        end
      end
    end
  end
end
