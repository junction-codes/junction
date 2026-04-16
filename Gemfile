# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "bcrypt"
gem "chartkick"
gem "propshaft"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  gem "brakeman", "~> 8.0"
  gem "factory_bot_rails", "~> 6.5"
  gem "faker", "~> 3.7"
  gem "rspec-rails", "~> 8.0"
  gem "rubocop-capybara", "~> 2.22"
  gem "rubocop-rails-omakase"
  gem "rubocop-rspec", "~> 3.8"
  gem "simplecov", "~> 0.22"
  gem "shoulda-matchers", "~> 7.0"
  gem "vcr", "~> 6.3"
end

group :development do
  gem "puma", "~> 8.0"
  gem "ruby_ui", "~> 1.1"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "~> 4.3"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "~> 3.4"
  gem "cuprite", "~> 0.17"
  gem "simplecov-cobertura", "~> 3.1"
end
