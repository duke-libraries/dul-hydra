require 'spec_helper'

describe CollectionsController do
  describe "#show" do
    let(:collection) { FactoryGirl.create(:collection_public_read) }
    let(:item1) { FactoryGirl.create(:item_public_read) }
    let(:item2) { FactoryGirl.create(:item_public_read) }
    let(:components1) { FactoryGirl.create_list(:component_with_content_public_read, 2) }
    let(:components2) { FactoryGirl.create_list(:component_with_content_public_read, 2) }
    let(:total_file_size) { 0 }
    before do
      item1.parent = collection
      item1.children = components1
      item1.save!
      item2.parent = collection
      item2.children = components2
      item2.save!
      components1.each {|c| total_file_size += c.content.size}
      components2.each {|c| total_file_size += c.content.size}
    end
    after do
      components1.each {|c| c.delete}
      components2.each {|c| c.delete}
      item1.delete
      item2.delete
      collection.delete
    end
    it "should list the number of items, components, and total file size" do
      assigns(:items).should eq(collection.children.size)
      assigns(:components).should eq(components1.size + components2.size)
      assigns(:total_file_size).should eq(total_file_size)
    end
  end
end
