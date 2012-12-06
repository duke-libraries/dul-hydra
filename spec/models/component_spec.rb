require 'spec_helper'

describe Component do
  before do
    @identifier = "test010010010"
    @title = "Awesome photo"
    @component = Component.create(:identifier => @identifier, :title => @title)
  end
  after do
    @component.delete
  end
  it "should have the right datastreams" do
    @component.datastreams["DC"].should be_kind_of ActiveFedora::Datastream
    @component.datastreams["RELS-EXT"].should be_kind_of ActiveFedora::RelsExtDatastream
    @component.datastreams["rightsMetadata"].should be_kind_of Hydra::Datastream::RightsMetadata
  end
  it "should be able to have an identifier" do # issue 27
    pending "move test to describable_spec"
    @component.identifier.first.should eq(@identifier)
  end
  it "should be findable by identifier" do
    pending "move test to describable_spec"
    results = Component.find_by_identifier(@identifier)
    results.should include(@component)
  end
  it "should be findable by a truncated identifier" do # issue 33
    pending "indexing identifier as symbol"
    trunc_id = @identifier[0, @identifier.length - 1]
    results = Component.find_by_identifier(trunc_id)
    results.should include(@component)
  end
  it "should be able to have a title" do # issue 28
    pending "move test to describable_spec"
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
      @component.container = @item
      @component.save
      @component.container.should eq(@item)
      @item.parts.should include(@component)
    end
    it "should be able to be added by an item to its list of components" do
      @item.parts << @component
      @item.parts.should include(@component)
      @component.container.should eq(@item)
    end
  end # relationships
end
