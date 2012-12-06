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
    # DC
    @item.datastreams["DC"].should be_kind_of ActiveFedora::Datastream
    # RELS-EXT
    @item.datastreams["RELS-EXT"].should be_kind_of ActiveFedora::RelsExtDatastream
    # rightsMetadata
    @item.datastreams["rightsMetadata"].should be_kind_of Hydra::Datastream::RightsMetadata
  end

  it "should be able to become a member of a collection" do
    @item.collection = @collection
    @item.save
    @item.collection.should eq(@collection)
    @collection.items.should include(@item)
  end

end
