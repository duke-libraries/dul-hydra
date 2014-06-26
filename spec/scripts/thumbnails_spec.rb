require 'spec_helper'
require 'digest'

module DulHydra::Scripts
  
  describe Thumbnails do
    
    let(:thumbnails_script) { DulHydra::Scripts::Thumbnails.new(collection.pid) }
    
    context "thumbnail does not exist" do
      
      context "child has thumbnail" do
        let(:collection) { FactoryGirl.create(:collection_with_items_and_components) }
        let(:items) { collection.children }
        let(:item) { items[0] }
        let(:children) { item.children }
        context "contentMetadata" do
          before do
            contentMetadata = <<-EOD
<?xml version="1.0"?>
<mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
  <fileSec>
    <fileGrp ID="GRP01" USE="Master Image">
      <file ID="FILE001">
        <FLocat LOCTYPE="URL" xlink:href="#{children[1].pid}/content"/>
      </file>
      <file ID="FILE002">
        <FLocat LOCTYPE="URL" xlink:href="#{children[0].pid}/content"/>
      </file>
    </fileGrp>
  </fileSec>
  <structMap>
    <div ID="DIV01" TYPE="image" LABEL="Images">
      <div ORDER="1">
        <fptr FILEID="FILE001"/>
      </div>
      <div ORDER="2">
        <fptr FILEID="FILE002"/>
      </div>
    </div>
  </structMap>
</mets>            
            EOD
            item.datastreams["contentMetadata"].content = contentMetadata
            item.save
            thumbnails_script.execute
            item.reload
          end
          it "should populate the thumbnail datastream from the first PID in contentMetadata" do
            expect(item.datastreams["thumbnail"].content).to_not be_nil
            expect(item.datastreams["thumbnail"].checksum).to eq(children[1].datastreams["thumbnail"].checksum)
          end
        end
        context "no contentMetadata" do
          before do
            iden = children[0].identifier
            children[0].identifier = children[1].identifier
            children[0].save
            children[1].identifier = iden
            children[1].save
            thumbnails_script.execute
            item.reload
          end
          it "should populate the thumbnail datastream from the first child (sorted by identifier)" do
            expect(item.datastreams["thumbnail"].content).to eq(children[1].datastreams["thumbnail"].content)
          end
        end
      end
      
      context "child does not have thumbnail" do
        let(:collection) { FactoryGirl.create(:collection) }
        let(:item) { FactoryGirl.create(:item) }
        let(:component) { FactoryGirl.create(:component) }
        before do
          item.children << component
          collection.children << item
          thumbnails_script.execute
          item.reload
        end
        it "should not populate the thumbnail datastream" do
          expect(item.datastreams["thumbnail"].content).to be_nil
        end
      end
      
    end
    
    context "thumbnail already exists" do
      let(:collection) { FactoryGirl.create(:collection_with_items_and_components) }
      let(:item) { collection.children[0] }
      let(:content) { StringIO.new("awesome image") }
      before do
        item.datastreams["thumbnail"].content = content
        item.save!
        thumbnails_script.execute
        item.reload
      end
      it "should not alter the existing thumbnail" do
        expect(item.datastreams["thumbnail"].content).to eq("awesome image")
      end
    end
    
  end
  
end
