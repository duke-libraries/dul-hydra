require 'spec_helper'
require 'shared_examples_for_dul_hydra_objects'

describe Component do
  it_behaves_like "a DulHydra object"
  context "validate content checksum" do
    let!(:component) { FactoryGirl.create(:component_with_content) }
    after { component.delete }
    before { component.validate_content_checksum! }
    it "should create a fixity check" do
      component.fixity_checks.length.should == 1
    end
    context "fixity check" do
      subject { component.fixity_checks.first }
      it { should be_kind_of(PreservationEvent) }
      its(:label) { should eq(DulHydra::Models::FixityCheckable::EVENT_DETAIL) }
      its(:outcome) { should eq(DulHydra::Models::FixityCheckable::EVENT_OUTCOME_PASSED) }
      its(:linking_obj_id_type) { should eq(DulHydra::Models::FixityCheckable::LINKING_OBJECT_ID_TYPE) }
      its(:linking_obj_id_value) { should eq(component.linking_object_id_value(component.content)) }
      its(:type) { should eq(DulHydra::Models::FixityCheckable::EVENT_TYPE) }
      its(:detail) { should eq(DulHydra::Models::FixityCheckable::EVENT_DETAIL) }
    end
  end
  context "relationships" do
    let!(:component) { FactoryGirl.create(:component) }
    let!(:item) { FactoryGirl.create(:item) }
    after do
      item.delete
      component.delete
    end
    context "when container set to item" do
      before do 
        component.container = item
        component.save
      end
      it "should be a part of the item" do
        item.parts.should include(component)
      end
    end
    context "when added to item's parts" do
      before { item.parts << component }
      it "should have the item as container" do
        component.container.should eq(item)
      end
    end
  end # relationships
end
