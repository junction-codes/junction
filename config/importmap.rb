# frozen_string_literal: true

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from Junction::Engine.root.join("app/javascript/controllers"), under: "controllers"
pin "@floating-ui/dom", to: "@floating-ui--dom.js" # @1.8.0
pin "@floating-ui/core", to: "@floating-ui--core.js" # @1.8.0
pin "@floating-ui/utils", to: "@floating-ui--utils.js" # @0.2.12
pin "@floating-ui/utils/dom", to: "@floating-ui--utils--dom.js" # @0.2.12
pin "cytoscape" # @3.34.1
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
