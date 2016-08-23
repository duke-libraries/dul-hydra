module Duracloud
  class Fcrepo3ObjectManifest

    def self.space_id
      DulHydra.duracloud_space
    end

    attr_reader :object

    def initialize(object)
      @object = object
    end

    def entries
      @entries ||= ManifestEntry.fcrepo3(self.class.space_id, object.internal_uri)
    end

    def entry_map
      @entry_map ||= Hash.new.tap do |emap|
        emap[:datastreams] = {}
        entries.each do |entry|
          resource_id = entry.content_id.split(/%2F/).last
          if resource_id == URI.encode_www_form_component(object.id)
            emap[:object] = entry
          else
            emap[:datastreams][resource_id] = entry
          end
        end
      end
    end

  end
end
