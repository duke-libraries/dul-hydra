require 'spec_helper'

describe Component do

  before do
    @component = Component.create
    @item = Item.create
  end
 
  after do
    @component.delete
    @item.delete
  end

  it "should have a DC datastream" do
    @component.datastreams["DC"].should_not be_nil
  end

  it "should have a RELS-EXT datastream" do 
    @component.datastreams["RELS-EXT"].should_not be_nil
  end
  
  it "should be able to retrieve the component" do
    c = Component.find(@component.pid)
    c.pid.should eq(@component.pid)
  end

  it "should be able to be made part of an item" do
    @component.part_of_append(@item)
    @component.save
    @component.part_of.should include(@item)
  end

end
