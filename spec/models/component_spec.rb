require 'spec_helper'

describe Component do

  before do
    @component = Component.create
  end
 
  after do
    @component.delete
  end

  it "should have the right datastreams" do
    # DC
    @component.datastreams["DC"].should_not be_nil
    @component.DC.should be_kind_of ActiveFedora::Datastream
    # RELS-EXT
    @component.datastreams["RELS-EXT"].should_not be_nil
    @component.RELS_EXT.should be_kind_of ActiveFedora::Datastream
  end
  
  describe "make part of item" do

    before do
      @item = Item.create
    end

    after do
      @item.delete
    end

    it "should be able to be made part of an item" do
      @component.item = @item
      @component.save
      @component.item.should eq(@item)
      @item.components.should include(@component)
    end

  end

end
