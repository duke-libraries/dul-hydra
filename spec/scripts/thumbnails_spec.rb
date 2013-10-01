require 'spec_helper'
require 'digest'

module DulHydra::Scripts
  
  describe Thumbnails do
    
    let(:thumbnails_script) { DulHydra::Scripts::Thumbnails.new(collection.pid) }
    
    after do
      collection.children.each do |item|
        item.children.each do |component|
          component.admin_policy.delete if component.admin_policy
          component.delete
        end
        item.reload
        item.admin_policy.delete if item.admin_policy
        item.delete
      end
      collection.reload
      collection.admin_policy.delete if collection.admin_policy
      collection.delete
    end
    
    context "thumbnail does not exist" do
      
      context "child has thumbnail" do
        let(:collection) { FactoryGirl.create(:collection_has_apo_with_items_and_components) }
        let(:items) { collection.children }
        context "contentMetadata" do
          let(:item) { items[0] }
          before do
            contentMetadata = <<-EOD
<?xml version="1.0"?>
<mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
  <fileSec>
    <fileGrp ID="GRP01" USE="Master Image">
      <file ID="FILE001">
        <FLocat LOCTYPE="URL" xlink:href="#{item.children[1].pid}/content"/>
      </file>
      <file ID="FILE002">
        <FLocat LOCTYPE="URL" xlink:href="#{item.children[0].pid}/content"/>
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
            expect(item.datastreams["thumbnail"].checksum).to eq(item.children[1].datastreams["thumbnail"].checksum)
          end
        end
        context "no contentMetadata" do
          before do
            thumbnails_script.execute
            items.each { |item| item.reload }
          end
          it "should populate the thumbnail datastream from the first child" do
            items.each { |item| expect(item.datastreams["thumbnail"].content).to eq(item.children[0].datastreams["thumbnail"].content) }
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
        let(:collection) { FactoryGirl.create(:collection_has_apo_with_items_and_components) }
        let(:item) { collection.children[0] }
      before do
        file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'sample.pdf'))
        item.generate_thumbnail!(file)
        item.save
        file.close
        @thumbnail = item.datastreams["thumbnail"].content
        thumbnails_script.execute
        item.reload
      end
      it "should not alter the existing thumbnail" do
        expect(item.datastreams["thumbnail"].content).to eq(@thumbnail)
      end
    end
    
  end
  
end
