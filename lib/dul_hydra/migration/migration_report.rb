module DulHydra::Migration
  class MigrationReport < ActiveRecord::Base

    has_many :migration_timers, inverse_of: :migration_report, dependent: :destroy

    MIGRATION_NEEDED = 'NEEDED'.freeze
    MIGRATION_SUCCESS = 'SUCCESS'.freeze
    MIGRATION_FAILURE = 'FAILURE'.freeze

  end
end
