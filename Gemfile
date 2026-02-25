# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "bcrypt"
gem "chartkick"
gem "propshaft"

# TODO: Remove once https://github.com/Rails-Designer/icons/pull/5 has been
# merged and released.
gem "rails_icons", git: "https://github.com/Rails-Designer/rails_icons.git", ref: "07325b95f1ada4e233538583f0fa8f4707e1ee81"
gem "icons", git: "https://github.com/jamesiarmes/icons.git", branch: "boxicons"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", "~> 8.0"
  gem "factory_bot_rails", "~> 6.5"
  gem "faker", "~> 3.5"
  gem "rspec-rails", "~> 8.0"
  gem "rubocop-capybara", "~> 2.22"
  gem "rubocop-rails-omakase"
  gem "rubocop-rspec", "~> 3.8"
  gem "simplecov", "~> 0.22"
  gem "shoulda-matchers", "~> 7.0"
  gem "vcr", "~> 6.3"
end

group :development do
  gem "ruby_ui", "~> 1.1"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.2"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.4"
  gem "cuprite", "~> 0.17"
end
