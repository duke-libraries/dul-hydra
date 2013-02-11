require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'

describe Collection do
  it_behaves_like "a DulHydra object"
  
  context "children" do
    let(:collection) { FactoryGirl.create(:collection_has_item) }
    after do
      collection.items.first.delete
      collection.reload
      collection.delete
    end
    it "should be the same as its items" do
      collection.children.should eq(collection.items)
    end
  end
end
