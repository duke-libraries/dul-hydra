require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'
require 'support/shared_examples_for_has_thumbnail'

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

shared_examples "a Component with a Target" do
  it "should be the first component of the target" do
    expect(target.components.first).to eq(component)
  end
  it "should have the target as target" do
    expect(component.target).to eq(target)
  end
end

describe Component do

  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that has content"
  it_behaves_like "an object that has a thumbnail"

  context "relationships" do
    let!(:component) { FactoryGirl.create(:component) }
    let!(:item) { FactoryGirl.create(:item) }
    let!(:target) { FactoryGirl.create(:target) }
    after do
      target.delete
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
    context "#target=" do
      before do
        component.target = target
        component.save!
      end
      it_behaves_like "a Component with a Target"
    end
    context "when added to target's components" do
      before { target.components << component}
      it_behaves_like "a Component with a Target"
    end
  end # relationships

end
