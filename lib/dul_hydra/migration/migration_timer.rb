module DulHydra::Migration
  class MigrationTimer < ActiveRecord::Base

    belongs_to :migration_report, inverse_of: :migration_timers

    OBJECT_MIGRATION_EVENT = 'OBJECT_MIGRATION'.freeze
    RELATIONSHIP_MIGRATION_EVENT = 'RELATIONSHIP_MIGRATION'.freeze
    STRUCT_METADATA_MIGRATION_EVENT = 'STRUCT_METADATA_MIGRATION'.freeze
    SHA_1_GENERATION_EVENT = 'SHA_1_GENERATION'.freeze

  end
end
