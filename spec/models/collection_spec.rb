require 'spec_helper'

describe Collection do

  before do
    @collection_pid = "collection:1"
    @collection = Collection.create(:pid => @collection_pid)
  end

  after do
    @collection.delete
  end

  it "should have a DC datastream" do
    @collection.datastreams["DC"].should_not be_nil
  end

  it "should have a RELS-EXT datastream" do
    @collection.datastreams["RELS-EXT"].should_not be_nil
  end

  it "should be able to retrieve the item" do
    c = Collection.find(@collection_pid)
    c.pid.should eq(@collection_pid)
  end


end
