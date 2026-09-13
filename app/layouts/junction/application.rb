# frozen_string_literal: true

module Junction
  module Layouts
    # Main layout for the application.
    class Application < Base
      attr_reader :breadcrumbs

      # Initializes a new layout.
      #
      # @param breadcrumbs [Array<Hash>] Breadcrumb items to display.
      # @param user_attrs [Hash] Additional HTML attributes for the layout.
      def initialize(breadcrumbs: [], **user_attrs)
        @breadcrumbs = breadcrumbs

        super(**user_attrs)
      end

      def view_template(&block)
        doctype

        html(lang: I18n.locale) do
          head do
            meta_tags
            link_tags
            title { page_title }
            javascript_importmap_tags
          end

          body(class: "bg-background text-foreground") do
            div(data_controller: "sidebar",
                class: "flex h-screen overflow-hidden") do
              Sidebar()

              # The top bar belongs to the content column, not the whole
              # window. It starts where the rail ends, so the collapse toggle
              # sits against the rail edge and follows it.
              div(class: "flex-1 flex flex-col min-w-0") do
                render Components::ApplicationHeader.new(breadcrumbs:)

                main(data_sidebar_target: "content",
                     class: "flex-1 overflow-y-auto") do
                  div(class: "max-w-[1160px] mx-auto") { yield }
                end
              end
            end

            div(class: "fixed top-4 right-4 w-80 z-1000") do
              flash&.each do |type, message|
                Alert(variant: type) do |alert|
                  alert.description { message }
                end
              end
            end
          end
        end
      end

      private

      def meta_tags
        crawler_meta_tags
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        meta name: "apple-mobile-web-app-capable", content: "yes"
        meta name: "mobile-web-app-capable", content: "yes"
        csrf_meta_tags
        csp_meta_tag
        turbo_refreshes_with method: :morph, scroll: :preserve
      end

      def link_tags
        # TODO: Enable PWA manifest for installable apps (make sure to enable in
        # config/routes.rb too!)
        # link rel: 'manifest', href: pwa_manifest_path(format: :json)
        link rel: "icon", href: "/icon.png", type: "image/png"
        link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
        link rel: "apple-touch-icon", href: "/icon.png"
        stylesheet_link_tag stylesheet_asset, 'data-turbo-track': "reload"
      end

      def page_title
        @title.present? ? "#{t('app.title')} | #{@title}" : t("app.title")
      end
    end
  end
end
