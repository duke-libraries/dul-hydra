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

shared_examples "a Collection related to a Target" do
  it "should be the target's collection" do
    expect(collection).to eq(target.collection)
  end
  it "should have the target as first member of its targets" do
    expect(collection.targets.first).to eq(target)
  end
end

describe Collection do

  it_behaves_like "a DulHydra object"

  describe "terms delegated to defaultRights" do
    let(:collection) { Collection.new }
    before do
      collection.default_license_title = "License Title"
      collection.default_license_description = "License Description"
      collection.default_license_url = "http://library.duke.edu"
    end
    it "should set the terms correctly" do
      collection.defaultRights.license.title.first.should == "License Title"
      collection.defaultRights.license.description.first.should == "License Description"
      collection.defaultRights.license.url.first.should == "http://library.duke.edu"
    end
  end

  context "collection-item relationships" do
    let!(:collection) { FactoryGirl.create(:collection) }
    let!(:item) { FactoryGirl.create(:item) }
    context "#children.<<" do
      before { collection.children << item }
      it_behaves_like "a Collection related to an Item"
    end
    context "#items.<<" do
      before { collection.items << item }
      it_behaves_like "a Collection related to an Item"
    end
  end

  context "collection-target relationships" do
    let!(:collection) { FactoryGirl.create(:collection) }
    let!(:target) { FactoryGirl.create(:target) }
    context "#targets.<<" do
      before { collection.targets << target }
      it_behaves_like "a Collection related to a Target"
    end
  end

  context "validation" do
    let(:collection) { Collection.new }
    it "should require a title" do
      expect(collection).to_not be_valid
      expect(collection.errors.messages).to have_key(:title)
    end
  end

end
