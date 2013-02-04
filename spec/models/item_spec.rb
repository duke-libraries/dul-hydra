require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'

describe Item do
  it_behaves_like "a DulHydra object"
  before do
    @item = Item.create
    @collection = Collection.create
  end
  after do
    @collection.delete
    @item.delete
  end
  context "when collection attribute set to a collection" do
    it "should be a member of the collection's items" do
      @item.collection = @collection
      @item.save
      @collection.items.should include(@item)
    end
  end
end
