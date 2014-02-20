require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'

shared_examples "a Target related to a Component" do
  it "should have the component as its first component" do
    expect(target.components.first).to eq(component)
  end
  it "should be target for the component" do
    expect(component.target).to eq(target)
  end
end

shared_examples "a Target related to a Collection" do
  it "should be the first target of the collection" do
    expect(collection.targets.first).to eq(target)
  end
  it "should have the collection as collection" do
    expect(target.collection).to eq(collection)
  end
end

describe Target do

  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that has content"

  context "relationships" do
    let!(:component) { FactoryGirl.create(:component) }
    let!(:collection) { FactoryGirl.create(:collection) }
    let!(:target) { FactoryGirl.create(:target) }
    after do
      ActiveFedora::Base.destroy_all
    end
    context "#collection=" do
      before do 
        target.collection = collection
        target.save!
      end
      it_behaves_like "a Target related to a Collection"
    end
    context "when added to collection's targets" do
      before { collection.targets << target }
      it_behaves_like "a Target related to a Collection"
    end
    context "when set as component's target" do
      before do
        component.target = target
        component.save!
      end
      it_behaves_like "a Target related to a Component"      
    end
    context "when adding component as target" do
      before { target.components << component}
      it_behaves_like "a Target related to a Component"      
    end
  end # relationships

end
