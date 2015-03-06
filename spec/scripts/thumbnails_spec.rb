require 'spec_helper'

module DulHydra::Scripts
  
  describe Thumbnails do
    
    let(:thumbnails_script) { DulHydra::Scripts::Thumbnails.new(collection.pid) }
    
    context "thumbnail does not exist" do
      
      context "child has thumbnail" do
        let(:collection) { FactoryGirl.create(:collection) }
        let(:items) do
          item1 = FactoryGirl.create(:item)
          item1.children << Component.new.tap do |c| 
            c.identifier = ["comp01"]
            c.upload! fixture_file_upload('image1.tiff', 'image/tiff')
          end
          item1.children << Component.new.tap do |c| 
            c.identifier = ["comp02"]
            c.upload! fixture_file_upload('image2.tiff', 'image/tiff')
          end
          item1.parent = collection
          item1.save
          item2 = FactoryGirl.create(:item)
          item2.children << Component.new.tap do |c| 
            c.identifier = ["comp03"]
            c.upload! fixture_file_upload('image3.tiff', 'image/tiff')
          end
          item2.children << Component.new.tap do |c| 
            c.identifier = ["comp04"]
            c.upload! fixture_file_upload('image4.tiff', 'image/tiff') 
          end
          item2.parent = collection
          item2.save          
          [item1, item2]
        end
        let(:item) { items.first }
        let(:children) { item.children }
        before do
          iden = children[0].identifier.first
          children[0].identifier = [ children[1].identifier.first ]
          children[0].save
          children[1].identifier = [ iden ]
          children[1].save
          thumbnails_script.execute
          item.reload
        end
        it "should populate the thumbnail datastream from the first child (sorted by identifier)" do
          expect(item.datastreams["thumbnail"].content).to eq(children[1].datastreams["thumbnail"].content)
        end
      end
      
      context "child does not have thumbnail" do
        let(:collection) { FactoryGirl.create(:collection) }
        let(:item) { FactoryGirl.create(:item) }
        let(:component) { FactoryGirl.create(:component) }
        before do
          item.children << component
          collection.children << item
          component.thumbnail.delete
          thumbnails_script.execute
          item.reload
        end
        it "should not populate the thumbnail datastream" do
          expect(item.datastreams["thumbnail"].content).to be_nil
        end
      end
      
    end
    
    context "thumbnail already exists" do
      let(:collection) { FactoryGirl.create(:collection) }
      let(:item) { FactoryGirl.create(:item) }
      let(:component) { FactoryGirl.create(:component) }
      let(:content) { StringIO.new("awesome image") }
      before do
        item.parent = collection
        item.children << component
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
