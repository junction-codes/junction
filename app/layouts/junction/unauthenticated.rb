  # frozen_string_literal: true

module Junction
  module Layouts
    class Unauthenticated < Base
      def view_template(&block)
        doctype

        html do
          head do
            meta_tags
            link_tags
            title { page_title }
            javascript_importmap_tags
          end

          body(class: "bg-gray-50 dark:bg-gray-900") do
            main(class: "flex-1 overflow-y-auto transition-all duration-300 md:mx-10") do
              yield
            end

            div(
              style: "position: fixed; bottom: 2rem; right: 2rem; z-index: 50;",
              class: "rounded-full bg-white dark:bg-gray-800 shadow-lg p-3 flex items-center justify-center"
            ) do
              render Components::ThemeToggle
            end
          end
        end
      end

      private

      def meta_tags
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
        stylesheet_link_tag :tailwind, 'data-turbo-track': "reload"
      end

      def page_title
        @title.present? ? "#{t('app.title')} | #{@title}" : t("app.title")
      end
    end
  end
end
