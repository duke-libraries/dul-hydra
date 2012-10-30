require 'spec_helper'

describe Component do

  before do
    @identifier = "test010010010"
    @title = "Awesome photo"
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

  it "should be able to have an identifier" do # issue 27
    @component.identifier = @identifier
    @component.identifier.first.should eq(@identifier)
  end

  it "should be able to have a title" do # issue 28
    @component.title = @title
    @component.title.first.should eq(@title)
  end
  
  describe "relationships" do

    before do
      @item = Item.create
    end

    after do
      @item.delete
    end

    it "should be able to add itself to an item's list of components" do
      @component.item = @item
      @component.save
      @component.item.should eq(@item)
      @item.components.should include(@component)
    end

    it "should be able to be added by an item to its list of components" do
      @item.components << @component
      @item.components.should include(@component)
      @component.item.should eq(@item)
    end

  end

end
