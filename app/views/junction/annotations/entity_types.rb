# frozen_string_literal: true

module Junction
  module Views
    module Annotations
      # All annotations grouped by the kinds they're found on.
      class EntityTypes < Views::Base
        include PaneSwitch

        # Initializes the view.
        #
        # @param entity_type_tabs [Array<Hash>] List of entity type tabs.
        # @param breadcrumbs [Array<Hash>] Breadcrumb navigation items.
        def initialize(entity_type_tabs:, breadcrumbs: [])
          @entity_type_tabs = entity_type_tabs
          @breadcrumbs = breadcrumbs
        end

        def view_template
          turbo_frame_tag FRAME do
            SettingsPanes(default: @entity_type_tabs.first&.fetch(:id)) do |panes|
              index_pane(panes)
              detail_panes(panes)
            end
          end
        end

        private

        # Renders the index pane with a list of entity type tabs.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        def index_pane(panes)
          panes.index do |index|
            pane_switch(:entity_types)

            if @entity_type_tabs.empty?
              index.footnote { t(".empty_entity_types") }
              next
            end

            index.list do |list|
              @entity_type_tabs.each do |tab|
                list.item(value: tab.fetch(:id), label: tab.fetch(:label),
                          count: tab.fetch(:total_count), icon: tab[:icon],
                          icon_class: tint(tab))
              end
            end

            index.footnote { t(".counts_note") }
          end
        end

        # The classes for the tint of a kind's chip.
        #
        # @param tab [Hash] One entity type.
        # @return [String, nil] The tint class.
        def tint(tab)
          Components::KindChip::FOREGROUNDS[tab[:kind]]
        end

        # Renders the detail panes for each kind's tab.
        #
        # @param panes [Components::Settings::SettingsPanes] Settings panes
        #   component for the page.
        def detail_panes(panes)
          @entity_type_tabs.each do |tab|
            panes.detail(value: tab.fetch(:id)) do
              turbo_frame_tag "annotation_entity_type_#{tab.fetch(:id)}",
                              src: annotation_entity_type_path(tab.fetch(:id)),
                              loading: :lazy do
                Skeleton(class: "h-20")
              end
            end
          end
        end
      end
    end
  end
end
