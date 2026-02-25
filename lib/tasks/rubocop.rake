# frozen_string_literal: true

begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new unless Rake::Task.task_defined?(:rubocop)
rescue LoadError
  # RuboCop not installed, skip task
end
