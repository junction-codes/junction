# frozen_string_literal: true

begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new(:spec) unless Rake::Task.task_defined?(:spec)

  task :spec_deprecation_warning do
    warn <<~WARNING
      DEPRECATED: `rails spec` runs specs through a Rake task, which boots
      Rails once to load the task and again in the rspec subprocess it shells
      out to. Run RSpec directly instead:

        bundle exec rspec                       # the whole suite
        bundle exec rspec path/to/a_spec.rb     # one file
        bundle exec rspec path/to/a_spec.rb:42  # one example
        bundle exec rspec --only-failures       # just what failed last run

    WARNING
  end

  Rake::Task[:spec].enhance([ :spec_deprecation_warning ])
rescue LoadError
  # RSpec not installed, skip task
end
