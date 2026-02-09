# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "bcrypt"
gem "chartkick"
gem "propshaft"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", "~> 8.0", require: false
  gem "factory_bot_rails", "~> 6.5", require: false
  gem "faker", "~> 3.5", require: false
  gem "rspec-rails", "~> 8.0", require: false
  gem "rubocop-capybara", "~> 2.22", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", "~> 3.8", require: false
  gem "simplecov", "~> 0.22"
  gem "shoulda-matchers", "~> 7.0", require: false
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
