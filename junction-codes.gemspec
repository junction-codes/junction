# frozen_string_literal: true

require_relative "lib/junction/version"

Gem::Specification.new do |s|
  s.name        = "junction-codes"
  s.version     = Junction::VERSION
  s.licenses    = [ "MIT" ]
  s.summary     = "An internal developer portal framework inspired by Backstage and built on Rails."
  s.description = s.summary
  s.authors     = [ "James I. Armes" ]
  s.email       = "jamesiarmes@gmail.com"
  s.files       = Dir["lib/**/*"] + Dir["Gemfile"]
  s.extra_rdoc_files = %w[README.md CHANGELOG.md]
  s.homepage    = "https://github.com/junction-codes/junction"
  s.metadata    = {
    "bug_tracker_uri" => "https://github.com/junction-codes/junction/issues",
    "changelog_uri" => "https://github.com/junction-codes/junction/blob/main/CHANGELOG.md",
    "homepage_uri" => s.homepage,
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/junction-codes/junction"
  }

  s.required_ruby_version = ">= 3.4"

  s.add_dependency "action_policy", "~> 0.7"
  s.add_dependency "bcrypt", "~> 3.1"
  s.add_dependency "bootsnap", "~> 1.20"
  s.add_dependency "chartkick", "~> 5.2"
  s.add_dependency "importmap-rails", "~> 2.2"
  s.add_dependency "jbuilder", "~> 2.14"
  s.add_dependency "kamal", "~> 2.10"
  s.add_dependency "omniauth", "~> 2.1"
  s.add_dependency "omniauth-rails_csrf_protection", "~> 2.0"
  s.add_dependency "pg", "~> 1.6"
  s.add_dependency "phlex-rails", "~> 2.3"
  s.add_dependency "propshaft"
  s.add_dependency "puma", "~> 7.1"
  s.add_dependency "rails", "~> 8.1"
  s.add_dependency "rails_icons", "~> 1.5"
  s.add_dependency "ransack", "~> 4.4"
  s.add_dependency "solid_cable", "~> 3.0"
  s.add_dependency "solid_cache", "~> 1.0"
  s.add_dependency "solid_queue", "~> 1.3"
  s.add_dependency "stimulus-rails", "~> 1.3"
  s.add_dependency "tailwind_merge", "~> 1.3"
  s.add_dependency "tailwindcss-rails", "~> 4.4"
  s.add_dependency "thruster", "~> 0.1"
  s.add_dependency "turbo-rails", "~> 2.0"
  s.add_dependency "tzinfo-data", ">= 1.2025"
end
