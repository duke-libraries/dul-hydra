require 'spec_helper'

describe Item do

  before do
    @item = Item.create
    @collection = Collection.create
  end

  after do
    @item.delete
    @collection.delete
  end

  it "should have the right datastreams" do
    @item.datastreams["DC"].should_not be_nil
    @item.DC.should be_kind_of ActiveFedora::Datastream
    @item.datastreams["RELS-EXT"].should_not be_nil
    @item.RELS_EXT.should be_kind_of ActiveFedora::Datastream
  end

  it "should be able to become a member of a collection" do
    @item.collection = @collection
    @item.save
    @item.collection.should eq(@collection)
    @collection.items.should include(@item)
  end

end
