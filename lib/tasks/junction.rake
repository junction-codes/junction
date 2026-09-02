# frozen_string_literal: true

namespace :junction do
  desc "Check entity references that the database cannot constrain"
  task verify_entities: :environment do
    problems = Junction::EntityIntegrity.call

    if problems.empty?
      puts "✓ Entity references are sound."
      next
    end

    warn "Found #{problems.size} problem(s):"
    problems.each { |problem| warn "  #{problem}" }
    abort "Entity verification failed."
  end
end unless Rake::Task.task_defined?("junction:verify_entities")
