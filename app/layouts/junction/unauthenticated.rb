# frozen_string_literal: true

module Junction
  module Layouts
    class Unauthenticated < Base
      def view_template(&block)
        doctype

        html(lang: I18n.locale) do
          head do
            meta_tags
            link_tags
            title { page_title }
            javascript_importmap_tags
          end

          body(class: "bg-auth-backdrop") do
            main { yield }

            aside(aria_label: t("junction.components.theme_toggle.theme_toggle.label"),
                  class: "fixed bottom-8 right-8 z-50 flex items-center " \
                         "justify-center rounded-full border border-border " \
                         "bg-surface p-3 shadow-lg") do
              ThemeToggle()
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
