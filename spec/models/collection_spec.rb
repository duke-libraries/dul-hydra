require 'spec_helper'

describe Collection do

  before do
    @collection = Collection.create
  end

  after do
    @collection.delete
  end

  it "should have the right datastreams" do
    @collection.datastreams["DC"].should be_kind_of ActiveFedora::Datastream
    @collection.datastreams["RELS-EXT"].should be_kind_of ActiveFedora::RelsExtDatastream
    @collection.datastreams["rightsMetadata"].should be_kind_of Hydra::Datastream::RightsMetadata
  end

  it "should have default permissions" do
    @collection.permissions.should_not be_empty
  end

  it "should be able to retrieve the item" do
    c = Collection.find(@collection.pid)
    c.pid.should eq(@collection.pid)
  end

end
