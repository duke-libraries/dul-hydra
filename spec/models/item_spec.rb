require 'spec_helper'

describe Item do

  before do
    @item_pid = "item:1"
    @item = Item.create(:pid => @item_pid)
    @collection_pid = "collection:1"
    @collection = Collection.create(:pid => @collection_pid)
  end

  after do
    @item.delete
    @collection.delete
  end

  it "should be able to become a member of a collection" do
    @item.member_of_append(@collection)
    @item.save
    @item.member_of.should include(@collection)
  end

end
