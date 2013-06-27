require 'spec_helper'

module DulHydra::Scripts
  
  describe Thumbnails do
    
    let(:collection) { FactoryGirl.create(:collection) }
    let(:component) { FactoryGirl.create(:component_part_of_item_with_content) }
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
      
      context "contentMetadata" do
        it "should populate the thumbnail datastream from the first PID in contentMetadata"
      end
      
      context "no contentMetadata" do
        before do
          thumbnails_script.execute
          item.reload
        end
        it "should populate the thumbnail datastream from the first child" do
          expect(item.datastreams["thumbnail"].content).to eq(component.datastreams["thumbnail"].content)
#          item.datastreams["thumbnail"].content.should == component.datastreams["thumbnail"].content
        end
      end
      
      context "child does not have thumbnail" do
        it "should not populate the thumbnail datastream"
      end
      
    end
    
    context "thumbnail already exists" do
      it "should not alter the existing thumbnail"
    end
    
  end
  
end
