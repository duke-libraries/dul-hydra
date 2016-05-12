require 'migration_helper'

module DulHydra::Migration
  RSpec.describe MigrateStructMetadata, migration: true do
    let(:item3) { Item.new }
    let(:item4) { Item.new }
    let(:f3_struct_metadata_xml) do
      <<-EOS
        <?xml version="1.0"?>
        <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
          <structMap TYPE="default">
            <div ID="collectiona_efghi01003-images" TYPE="Images">
              <div ID="efghi010030010" ORDER="1">
                <fptr CONTENTIDS="info:fedora/test:19"/>
              </div>
              <div ID="efghi010030020" ORDER="2">
                <fptr CONTENTIDS="info:fedora/test:20"/>
              </div>
              <div ID="efghi010030030" ORDER="3">
                <fptr CONTENTIDS="info:fedora/test:21"/>
              </div>
            </div>
            <div ID="collectiona_efghi01003-documents" TYPE="Documents">
              <div ID="efghi01003" ORDER="1">
                <fptr CONTENTIDS="info:fedora/test:25"/>
              </div>
            </div>
          </structMap>
        </mets>
      EOS
    end
    let(:f4_struct_metadata_xml) do
      <<-EOS
        <?xml version="1.0"?>
        <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
          <structMap TYPE="default">
            <div ID="collectiona_efghi01003-images" TYPE="Images">
              <div ID="efghi010030010" ORDER="1">
                <fptr CONTENTIDS="test-19"/>
              </div>
              <div ID="efghi010030020" ORDER="2">
                <fptr CONTENTIDS="test-20"/>
              </div>
              <div ID="efghi010030030" ORDER="3">
                <fptr CONTENTIDS="test-21"/>
              </div>
            </div>
            <div ID="collectiona_efghi01003-documents" TYPE="Documents">
              <div ID="efghi01003" ORDER="1">
                <fptr CONTENTIDS="test-25"/>
              </div>
            </div>
          </structMap>
        </mets>
      EOS
    end
    before do
      item3.structMetadata.content = f3_struct_metadata_xml
      item3.save!
      item4.structMetadata.content = f4_struct_metadata_xml
      item4.save!
    end
    it "should queue the correct items for structural metadata migration" do
      expect(Resque).to receive(:enqueue).with(DulHydra::Migration::MigrateSingleObjectStructMetadataJob, item3.id)
      DulHydra::Migration::MigrateStructMetadata.migrate
    end
  end
end
