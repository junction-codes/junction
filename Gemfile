source "https://rubygems.org"

# Use specific branch of Rails
gem "rails", "~> 8.1"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Additional dependencies.
gem "chartkick", "~> 5.2"
gem "phlex-rails", "~> 2.3"
gem "omniauth", "~> 2.1"
gem "omniauth-github", "~> 2.0"
gem "omniauth-rails_csrf_protection", "~> 2.0"
gem "rails_icons", "~> 1.4"
gem "ransack", "~> 4.4"
gem "tailwind_merge", "~> 1.3"

# Plugins.
# TODO: Switch to released versions when available.
gem "junction-aws", git: "git@github.com:jamesiarmes/junction-aws.git", branch: "main"
gem "junction-github", git: "git@github.com:jamesiarmes/junction-github.git", branch: "main"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", "~> 7.1", require: false
  gem "factory_bot_rails", "~> 6.5", require: false
  gem "faker", "~> 3.5", require: false
  gem "rubocop-capybara", "~> 2.22", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", "~> 3.8", require: false
  gem "rspec-rails", "~> 8.0", require: false
  gem "simplecov", "~> 0.22", require: false
  gem "shoulda-matchers", "~> 6.5", require: false
  gem "vcr", "~> 6.3"
end

group :development do
  gem "ruby_ui", "~> 1.0"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.4"
  gem "cuprite", "~> 0.17"
end
