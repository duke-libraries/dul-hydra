require 'spec_helper'

module DulHydra::Scripts
  
  describe Thumbnails do
    
    let(:collection) { FactoryGirl.create(:collection) }
    let(:item) { component.parent }
    let(:thumbnails_script) { DulHydra::Scripts::Thumbnails.new(collection.pid) }
    
    before do
      item.parent = collection
      item.save!
    end
    
    after do
      component.destroy
      item.destroy
      collection.destroy
    end
    
    context "thumbnail does not exist" do
      
      context "child has thumbnail" do
        let(:component) { FactoryGirl.create(:component_part_of_item_with_content) }
#        context "contentMetadata" do
#          let(:component_2) { FactoryGirl.create(:component) }
#          before do
#            component_2.parent = item
#            file = File.open(File.join(Rails.root, 'spec', 'fixtures', 'sample.pdf'))
#            component_2.content.content = file
#            component_2.save
#            file.close
#            component_2.generate_content_thumbnail!
#            component_2.save
#            contentMetadata = <<-EOD
#<?xml version="1.0"?>
#<mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
#  <fileSec>
#    <fileGrp ID="GRP01" USE="Master Image">
#      <file ID="FILE001">
#        <FLocat LOCTYPE="URL" xlink:href="#{component_2.pid}/content"/>
#      </file>
#      <file ID="FILE002">
#        <FLocat LOCTYPE="URL" xlink:href="#{component.pid}/content"/>
#      </file>
#    </fileGrp>
#  </fileSec>
#  <structMap>
#    <div ID="DIV01" TYPE="image" LABEL="Images">
#      <div ORDER="1">
#        <fptr FILEID="FILE001"/>
#      </div>
#      <div ORDER="2">
#        <fptr FILEID="FILE002"/>
#      </div>
#    </div>
#  </structMap>
#</mets>            
#            EOD
#            puts contentMetadata
#          end
#          before do
#            thumbnails_script.execute
#            item.reload
#          end
#          it "should populate the thumbnail datastream from the first PID in contentMetadata" do
#            expect(item.datastreams["thumbnail"].content).to_not be_nil
#          end
#        end
        context "no contentMetadata" do
          before do
            thumbnails_script.execute
            item.reload
          end
          it "should populate the thumbnail datastream from the first child" do
            expect(item.datastreams["thumbnail"].content).to eq(component.datastreams["thumbnail"].content)
          end
        end
      end
      
      context "child does not have thumbnail" do
        let(:component) { FactoryGirl.create(:component_part_of_item) }
        before do
          thumbnails_script.execute
          item.reload
        end
        it "should not populate the thumbnail datastream" do
          expect(item.datastreams["thumbnail"].content).to be_nil
        end
      end
      
    end
    
    context "thumbnail already exists" do
      let(:component) { FactoryGirl.create(:component_part_of_item_with_content) }
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
