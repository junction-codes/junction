# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "tw-animate-css", integrity: "sha384-Jb1jRNz7RTZaBZ/36mLdcxKYLtxKnA3dLxARRf1WZa81rTmcjuUMudxpy8FxNssE" # @1.3.6
pin "@tailwindcss/forms", to: "@tailwindcss--forms.js", integrity: "sha384-KQX36O7wdYuD3nnpc7j5bFfnO1hZZmbG00Bd8g9mARvIg+QiP6YuizfA3r0E7aK7" # @0.5.10
pin "mini-svg-data-uri", integrity: "sha384-WGcyge/fDeaekKTUlNhxNMWDxeL6nFvm5jintGX3CvEk31+L/L6nIz3DBf3iscib" # @1.4.4
pin "tailwindcss/colors", to: "tailwindcss--colors.js", integrity: "sha384-4jNFdTlW7wPEVT8Wk+V1ZRsdEyKJ4VHCmqN/ar0l8sG1ASp4uiy3ByY3XLJcuNG4" # @4.1.11
pin "tailwindcss/defaultTheme", to: "tailwindcss--defaultTheme.js", integrity: "sha384-0xlrnryJWOep0PgJ3FCU44WX5qfXXtbvTrFHvt8aNO1/uqp335nORHPrOZx8pIfz" # @4.1.11
pin "tailwindcss/plugin", to: "tailwindcss--plugin.js", integrity: "sha384-5YzdB8gWHuusdzASFt7sF7ogXJgjTFmV/XH8BLZV4a91EHXVCXIfqVs21xCyt45f" # @4.1.11
pin "@tailwindcss/typography", to: "@tailwindcss--typography.js", integrity: "sha384-zaWB8TorQa8b50p5yDQCHeSelJbR+vN9eB6wW3qKVe55zai1yZYtx7CHUoRLBZxu" # @0.5.16
pin "cssesc", integrity: "sha384-tQRjICxphgw+j3EuD+TkKJjMLtg+v6ePj40L+wU2wH2jMyA1VT6cjizFvWWy2LuM" # @3.0.0
pin "lodash.castarray", integrity: "sha384-m0SXVlmRAY1mE8L0eqxPdP85dT147pcFu3usA0iEKZMaH5byZmWL8R69glRx5h9u" # @4.4.0
pin "lodash.isplainobject", integrity: "sha384-N9NxhUbRvkOsXtszYa5UBn9IUaGgLK9Wwb9L7ADGHgl7lWVBF4s5fseQhEeEtshz" # @4.0.6
pin "lodash.merge", integrity: "sha384-veVSTvJPToM1mANchIzy2EXHZx0xYzeGQ0doyMmWp3xwGa92SQ9ipPpT3aAnjKEq" # @4.6.2
pin "postcss-selector-parser", integrity: "sha384-Wdha+jbIuna5YHaf7rQcgTHkxtgL7jy3a6Ydh56hjXrR9j4iQsjuTbMF8flwXwXL" # @6.0.10
pin "util-deprecate", integrity: "sha384-LGPtINfsK3RkAM2O5TxILNi1l4ENjenU++6OcyzpVtpn6yCzbnDzERfaUJ0T8Yz8" # @1.0.2
