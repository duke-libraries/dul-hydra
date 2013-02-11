require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'

shared_examples "a Collection related to an Item" do
  it "should be the item's collection" do
    expect(collection).to eq(item.collection)
  end
  it "should have the item as first member of its children and items" do
    expect(collection.children.first).to eq(item)
    expect(collection.items.first).to eq(item)
  end
end

describe Collection do
  it_behaves_like "a DulHydra object"
  
  context "collection-item relationships" do
    let!(:collection) { FactoryGirl.create(:collection) }
    let!(:item) { FactoryGirl.create(:item) }
    after do
      collection.delete
      item.delete
    end
    context "#children.<<" do
      before { collection.children << item }
      it_behaves_like "a Collection related to an Item"
    end
    context "#items.<<" do
      before { collection.items << item }
      it_behaves_like "a Collection related to an Item"
    end
  end
end
