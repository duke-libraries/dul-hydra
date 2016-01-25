module DulHydra::Migration
  class StructMetadata

    FEDORA3_URI_REGEXP = /info:fedora\/([\w]+:[\d]+)/

    attr_accessor :item

    def initialize(item)
      @item = item
    end

    def migrate
      unless item.has_struct_metadata?
        raise FedoraMigrate::Errors::MigrationError, "#{item.id}: No structMetadata to migrate"
      end
      old_struct_metadata = item.structMetadata.content
      new_struct_metadata = transmogrify(old_struct_metadata)
      if old_struct_metadata == new_struct_metadata
        raise FedoraMigrate::Errors::MigrationError, "#{item.id}: Migration did not change structMetadata"
      else
        item.structMetadata.content = new_struct_metadata
        unless item.save
          raise FedoraMigrate::Errors::MigrationError, "#{item.id}: Unable to save migrated structMetadata"
        end
      end
    end

    def transmogrify(struct_metadata_xml)
      sm = struct_metadata_xml.clone
      while m = FEDORA3_URI_REGEXP.match(sm)
        sm = sm.sub(m[0], f4_id(m[1]))
      end
      sm
    end

    private

    def f4_id(f3_pid)
      begin
        ActiveFedora::Base.where(Ddr::Index::Fields::FCREPO3_PID => f3_pid).first.id
      rescue NoMethodError
        raise FedoraMigrate::Errors::MigrationError, "#{item.id}: Unable to find Fedora 4 ID for #{f3_pid}"
      end
    end

  end
end
