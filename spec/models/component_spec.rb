require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'

shared_examples "a Component related to an Item" do
  it "should be the first part of the item" do
    expect(item.parts.first).to eq(component)
  end
  it "should have the item as container, parent and item" do
    expect(component.container).to eq(item)
    expect(component.parent).to eq(item)
    expect(component.item).to eq(item)
  end
end

describe Component do

  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that has content"

  context "relationships" do
    let!(:component) { FactoryGirl.create(:component) }
    let!(:item) { FactoryGirl.create(:item) }
    after do
      item.delete
      component.delete
    end
    context "#container=" do
      before do 
        component.container = item
        component.save!
      end
      it_behaves_like "a Component related to an Item"
    end
    context "#parent=" do
      before do
        component.parent = item
        component.save!
      end
      it_behaves_like "a Component related to an Item"
    end
    context "#item=" do
      before do
        component.parent = item
        component.save!
      end
      it_behaves_like "a Component related to an Item"
    end
    context "when added to item's parts" do
      before { item.parts << component }
      it_behaves_like "a Component related to an Item"
    end
  end # relationships

end
