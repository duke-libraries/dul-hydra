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

  it "should have a DC datastream" do
    @item.datastreams["DC"].should_not be_nil
  end

  it "should have a RELS-EXT datastream" do
    @item.datastreams["RELS-EXT"].should_not be_nil
  end

  it "should be able to retrieve the item" do
    i = Item.find(@item.pid)
    i.pid.should eq(@item.pid)
  end

  it "should be able to become a member of a collection" do
    @item.member_of_append(@collection)
    @item.save
    @item.member_of.should include(@collection)
  end

end
