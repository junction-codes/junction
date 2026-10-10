# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # The annotations settings page.
      class Index < Views::Base
        # Initializes the view.
        #
        # @param breadcrumbs [Array<Hash>] Breadcrumb navigation items.
        def initialize(breadcrumbs: [])
          @breadcrumbs = breadcrumbs
        end

        def view_template
          render Junction::Layouts::Application.new(breadcrumbs: @breadcrumbs) do
            SettingsPage(title: t(".title"), description: t(".description")) do |page|
              page.callout(variant: :warning) { t(".secret_warning") }

              turbo_frame_tag "annotations_panes", src: annotation_keys_path,
                                                   loading: :lazy do
                Skeleton(class: "h-96")
              end
            end
          end
        end
      end
    end
  end
end
