module DulHydra::Migration
  class LegacyOriginalFilename < Migrator

    # source: Rubydora::DigitalObject
    # target: ActiveFedora::Base

    def migrate
      target.legacy_original_filename = nil if target.legacy_original_filename
    end

  end
end
