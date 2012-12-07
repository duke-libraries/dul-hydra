require 'spec_helper'
require 'shared_examples_for_describables'

describe Item do
  it_behaves_like "a describable object"
  before do
    @item = Item.create
    @collection = Collection.create
  end
  after do
    @item.delete
    @collection.delete
  end
  context "when collection attribute set to a collection" do
    it "should be a member of the collection's items" do
      @item.collection = @collection
      @item.save
      @collection.items.should include(@item)
    end
  end
end
