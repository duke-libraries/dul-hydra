require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'

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
      it "should be a part of the item" do
        item.parts.should include(component)
      end
    end
    context "#parent=" do
      before do
        component.parent = item
        component.save!
      end
      it "should be a part of the item" do
        item.parts.should include(component)
      end
    end
    context "when added to item's parts" do
      before { item.parts << component }
      it "should have the item as container and parent" do
        component.container.should eq(item)
        component.parent.should eq(item)
      end
    end
  end # relationships

end
