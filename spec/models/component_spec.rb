require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'

shared_examples "a Component related to an Item" do
  it "should be the first part of the item" do
    expect(item.parts.first).to eq(component)
  end
  it "should have the item as parent and item" do
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

describe Component, type: :model, components: true do

  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that can have content"

  context "#collection" do
    context "orphan component" do
      subject { component }
      let(:component) { FactoryGirl.create(:component) }

      describe '#collection' do
        subject { super().collection }
        it { is_expected.to be_nil }
      end
    end
    context "belongs to orphan item" do
      subject { component }
      let(:component) { FactoryGirl.create(:component) }
      let(:item) { FactoryGirl.create(:item) }
      before do
        component.parent = item
        component.save!
      end

      describe '#collection' do
        subject { super().collection }
        it { is_expected.to be_nil }
      end
    end
    context "belongs to item in collection" do
      before do
        item.collection = collection
        item.children << component
        item.save
        component.reload
      end
      let(:component) { FactoryGirl.create(:component) }
      let(:item) { FactoryGirl.create(:item) }
      let(:collection) { FactoryGirl.create(:collection) }
      it "should have the collection as its parent's parent" do
        expect(collection).to eq(component.parent.parent)
      end
    end
  end

  context "relationships" do
    let!(:component) { FactoryGirl.create(:component) }
    let!(:item) { FactoryGirl.create(:item) }
    let!(:target) { FactoryGirl.create(:target) }
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
