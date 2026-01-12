# frozen_string_literal: true

begin
  require "rubocop/rake_task"

  RuboCop::RakeTask.new
rescue LoadError
  # RuboCop not installed, skip task
end
