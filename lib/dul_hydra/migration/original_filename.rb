module DulHydra::Migration
  class OriginalFilename < Migrator

    # source: Rubydora::DigitalObject
    # target: ActiveFedora::Base

    def migrate
      if target.legacy_original_filename && target.attached_files.key?("content")
        target.content.original_name = target.legacy_original_filename
        target.legacy_original_filename = nil
      end
    end

  end
end
