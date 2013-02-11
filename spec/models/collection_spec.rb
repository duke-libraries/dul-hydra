require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'

describe Collection do
  it_behaves_like "a DulHydra object"
  
  context "collection-item relationships" do
    subject { collection }
    let!(:collection) { FactoryGirl.create(:collection) }
    let!(:item) { FactoryGirl.create(:item) }
    after do
      collection.delete
      item.delete
    end
    context "#children" do
      before { collection.children << item }
      its(:items) { should eq(collection.children) }
      it { should eq(item.collection) }
    end
    context "#items" do
      before { collection.items << item }
      its(:children) { should eq(collection.items) }
      it { should eq(item.collection) }
    end
  end
end
