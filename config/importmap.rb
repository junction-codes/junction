# frozen_string_literal: true

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from Junction::Engine.root.join("app/javascript/controllers"), under: "controllers"
pin "tw-animate-css"
pin "@tailwindcss/forms", to: "@tailwindcss--forms.js"
pin "mini-svg-data-uri"
pin "tailwindcss/colors", to: "tailwindcss--colors.js"
pin "tailwindcss/defaultTheme", to: "tailwindcss--defaultTheme.js"
pin "tailwindcss/plugin", to: "tailwindcss--plugin.js"
pin "@tailwindcss/typography", to: "@tailwindcss--typography.js"
pin "cssesc"
pin "lodash.castarray"
pin "lodash.isplainobject"
pin "lodash.merge"
pin "postcss-selector-parser"
pin "util-deprecate"
pin "@floating-ui/dom", to: "@floating-ui--dom.js" # @1.7.5
pin "@floating-ui/core", to: "@floating-ui--core.js" # @1.7.5
pin "@floating-ui/utils", to: "@floating-ui--utils.js" # @0.2.11
pin "@floating-ui/utils/dom", to: "@floating-ui--utils--dom.js" # @0.2.11
pin "cytoscape"
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
