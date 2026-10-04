# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # The annotation keys in use, grouped by who they belong to.
      class Keys < Views::Base
        include PaneSwitch

        # Initializes the view.
        #
        # @param annotation_key_tabs [Array<Hash>] List of annotation key tabs.
        # @param breadcrumbs [Array<Hash>] Breadcrumb navigation items.
        def initialize(annotation_key_tabs:, breadcrumbs: [])
          @annotation_key_tabs = annotation_key_tabs
          @breadcrumbs = breadcrumbs
        end

        def view_template
          turbo_frame_tag FRAME do
            SettingsPanes(default: @annotation_key_tabs.first&.fetch(:id)) do |panes|
              index_pane(panes)
              detail_panes(panes)
            end
          end
        end

        private

        # Renders the index pane with a list of annotation key tabs.
        #
        # @param panes [Components::Settings::SettingsPanes] Both panes.
        def index_pane(panes)
          panes.index do |index|
            pane_switch(:keys)

            if @annotation_key_tabs.empty?
              index.footnote { t(".empty") }
              next
            end

            index.filter(placeholder: t(".filter", count: @annotation_key_tabs.size))

            index.list do |list|
              namespaces.each do |namespace, keys|
                key_group(list, namespace, keys)
              end
            end

            index.footnote { undeclared_legend }
          end
        end

        # One namespace and the keys it holds.
        #
        # A namespace is marked as unclaimed when no plugin defines any keys
        # within the domain.
        #
        # @param list [Components::Settings::SettingsIndexList] The rows.
        # @param namespace [String, nil] The namespace, if the keys have one.
        # @param keys [Array<Hash>] Its keys.
        def key_group(list, namespace, keys)
          unclaimed = keys.none? { |key| key.fetch(:declared) }

          list.group(namespace || t(".no_namespace"), marker: unclaimed) do |group|
            keys.each do |key|
              group.item(value: key.fetch(:id), label: key.fetch(:name),
                         count: key.fetch(:total_count),
                         marker: unclaimed ? false : !key.fetch(:declared))
            end
          end
        end

        # Renders the detail panes for each annotation key tab.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        def detail_panes(panes)
          @annotation_key_tabs.each do |tab|
            panes.detail(value: tab.fetch(:id)) do
              turbo_frame_tag "annotation_key_#{tab.fetch(:id)}",
                              src: annotation_key_path(tab.fetch(:id)),
                              loading: :lazy do
                Skeleton(class: "h-20")
              end
            end
          end
        end

        # Renders a legend explaining the meaning of the marker beside a key.
        #
        # @return [String] The legend HTML.
        def undeclared_legend
          div(class: "flex items-center gap-1.5") do
            span(class: "shrink-0 w-[5px] h-[5px] rounded-full bg-warning",
                 aria_hidden: "true")
            span { t(".undeclared_legend") }
          end
        end

        # The keys grouped by the namespace they belong to, in the order the
        # service ranked them.
        #
        # @return [Hash<String, Array<Hash>>] Keys by namespace.
        def namespaces
          @namespaces ||= @annotation_key_tabs.group_by { |tab| tab.fetch(:namespace) }
        end
      end
    end
  end
end
