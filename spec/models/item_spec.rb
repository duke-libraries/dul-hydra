require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'

describe Item do
  it_behaves_like "a DulHydra object"

  context "item-collection relationships" do
    subject { item }
    let!(:item) { FactoryGirl.create(:item) }
    let!(:collection) { FactoryGirl.create(:collection) }
    after do
      collection.delete
      item.delete
    end
    context "#collection=" do
      before do
        item.collection = collection
        item.save!
      end
      its(:parent) { should eq(item.collection) }
      it { should eq(collection.items.first) }
    end
    context "#parent=" do
      before do
        item.parent = collection
        item.save!
      end
      its(:collection) { should eq(item.parent) }
      it { should eq(collection.items.first) }
    end
  end

  context "item-component relationships" do
    subject { item }
    let!(:item) { FactoryGirl.create(:item) }
    let!(:component) { FactoryGirl.create(:component) }
    after do
      item.delete
      component.delete
    end
    context "#parts" do
      before { item.parts << component }
      its(:children) { should eq(item.parts) }
      it { should eq(component.container) }
    end
    context "#children" do
      before { item.children << component }
      its(:parts) { should eq(item.children) }
      it { should eq(component.container) }
    end
  end
end
