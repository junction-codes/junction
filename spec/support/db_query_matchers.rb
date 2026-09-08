# frozen_string_literal: true

require "db-query-matchers"

DBQueryMatchers.configure do |config|
  # Only the queries a request actually makes are interesting. Transaction
  # bookkeeping from the per-example rollback, column lookups Rails issues the
  # first time it touches a table, and the query cache's repeat hits are all
  # noise that varies with example ordering.
  config.ignores = [ /^SAVEPOINT/, /^RELEASE SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/ ]
  config.schemaless = true
  config.ignore_cached = true
end
