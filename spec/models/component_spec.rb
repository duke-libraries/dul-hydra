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
      its(:outcome) { should eq("PASSED") }
      its(:linking_obj_id_type) { should eq("datastream") }
      its(:linking_obj_id_value) { should eq("info:fedora/#{component.pid}/datastreams/content?asOfDateTime=" + component.content.profile["dsCreateDate"].strftime("%Y-%m-%dT%H:%M:%S.%LZ")) }
      its(:type) { should eq(PreservationEvent::FIXITY_CHECK) }
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
