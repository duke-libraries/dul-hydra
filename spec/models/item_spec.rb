require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content_metadata'

shared_examples "an Item related to a Collection" do
  it "should have the collection as parent and collection" do
    expect(item.parent).to eq(collection)
    expect(item.collection).to eq(collection)
  end
  it "should be the first member of the collection's items" do
    expect(collection.items.first).to eq(item)
  end
end

shared_examples "an Item related to a Component" do
  it "should have the component as first member of its parts, children, and components" do
    expect(item.parts.first).to eq(component)
    expect(item.children.first).to eq(component)
    expect(item.components.first).to eq(component)
  end
  it "should be the component's container" do
    expect(item).to eq(component.container)
  end
end

describe Item do
  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that has content metadata"

  context "relationships" do
    let!(:item) { FactoryGirl.create(:item) }
    after do
      ActiveFedora::Base.destroy_all
    end
    context "with a collection" do
      let!(:collection) { FactoryGirl.create(:collection) }
      context "#collection=" do
        before do
          item.collection = collection
          item.save!
        end
        it_behaves_like "an Item related to a Collection"
      end
      context "#parent=" do
        before do
          item.parent = collection
          item.save!
        end
        it_behaves_like "an Item related to a Collection"
      end
    end
    context "with components" do
      let!(:component) { FactoryGirl.create(:component) }
      context "#parts.<<" do
        before { item.parts << component }
        it_behaves_like "an Item related to a Component"
      end
      context "#children.<<" do
        before { item.children << component }
        it_behaves_like "an Item related to a Component"
      end
      context "#components.<<" do
        before { item.components << component }
        it_behaves_like "an Item related to a Component"
      end
    end
  end
end
