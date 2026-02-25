# frozen_string_literal: true

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec) unless Rake::Task.task_defined?(:spec)
rescue LoadError
  # RSpec not installed, skip task
end
