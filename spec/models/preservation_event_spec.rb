require 'spec_helper'
require 'support/shared_examples_for_preservation_events'

# Override datastream method #dsChecksumValid to always return false
def ds_checksum_valid_false(ds)
  class << ds
    def dsChecksumValid; false; end
  end
end

describe PreservationEvent do

  describe "validations" do
    let!(:obj) { FactoryGirl.create(:component_with_content) }
    let!(:pe) { PreservationEvent.fixity_check(obj) }
    after { obj.destroy }
    it "should validate event_date_time" do
      pe.valid?.should be_true
      pe.event_date_time = nil
      pe.valid?.should be_false
    end
    it "should validate event_type" do
      pe.valid?.should be_true
      PreservationEvent::EVENT_TYPES.each do |t|
        pe.event_type = t
        pe.valid?.should be_true
      end
      pe.event_type = "foo"
      pe.valid?.should be_false
    end
    it "should validate event_outcome" do
      pe.valid?.should be_true
      PreservationEvent::EVENT_OUTCOMES.each do |o|
        pe.event_outcome = o
        pe.valid?.should be_true
      end
      pe.event_outcome = "foo"
      pe.valid?.should be_false
    end
    it "should validate event_id_type" do
      pe.valid?.should be_true
      PreservationEvent::EVENT_ID_TYPES.each do |t|
        pe.event_id_type = t
        pe.valid?.should be_true
      end
      pe.event_id_type = "foo"
      pe.valid?.should be_false
    end
    it "should validate event_id_value" do
      pe.valid?.should be_true
      pe.event_id_value = nil
      pe.valid?.should be_false
    end
    context "validate linking_object_id_type and linking_object_id_value" do
      it "should validate the presence of the linking_object_id_value if the linking_object_id_type is present" do
        pe.valid?.should be_true
        pe.linking_object_id_type.should_not be_nil
        pe.linking_object_id_value.should_not be_nil
        pe.linking_object_id_value = nil
        pe.valid?.should be_false
      end
      it "should validate the presence of the linking_object_id_type if the linking_object_id_value is present" do
        pe.valid?.should be_true
        pe.linking_object_id_value.should_not be_nil
        pe.linking_object_id_type.should_not be_nil
        pe.linking_object_id_type = nil
        pe.valid?.should be_false
      end
      it "should validate the existence and proper type of object referenced in the linking_object_id_value if the linking_object_id_type is 'object'" do
        pe.valid?.should be_true
        pe.linking_object_id_type.should == PreservationEvent::OBJECT
        pe.for_object.should be_kind_of(DulHydra::Models::HasPreservationEvents)
        pe.linking_object_id_value = "foo:bar"
        pe.valid?.should be_false
      end
    end
  end

  describe "#for_object?" do
    context "linking_object_id_type is 'object'" do
      subject { PreservationEvent.new(:linking_object_id_type => PreservationEvent::OBJECT) }
      its(:for_object?) { should be_true }
    end
    context "linking_object_id_type is not 'object'" do
      subject { PreservationEvent.new(:linking_object_id_type => PreservationEvent::DATASTREAM) }
      its(:for_object?) { should be_false }
    end
  end

  describe "#for_object=" do
    before { pe.for_object = obj }
    let(:obj) { Component.new(pid: "foo:bar") }
    let(:pe) { PreservationEvent.new }
    it "should set the appropriate PreservationEvent attributes" do
      pe.linking_object_id_type.should == PreservationEvent::OBJECT
      pe.linking_object_id_value.should == obj.pid
    end
  end

  describe "#for_object" do
    before { pe.for_object = obj }
    after { obj.delete }
    let(:obj) { Component.create }
    let(:pe) { PreservationEvent.new }
    it "should return the object associated with the PreservationEvent" do
      pe.for_object.should == obj
    end
  end

  describe ".fixity_check" do
    subject { PreservationEvent.fixity_check(obj) }
    after { obj.destroy }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check success preservation event"
    end
    context "failure" do
      before { ds_checksum_valid_false(obj.datastreams["content"]) }
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check failure preservation event"
    end
  end

  describe ".fixity_check!" do
    subject { PreservationEvent.fixity_check!(obj) }
    after { obj.destroy }
    context "success" do
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check success preservation event"
    end
    context "failure" do
      before { ds_checksum_valid_false(obj.datastreams["content"]) }
      let(:obj) { FactoryGirl.create(:component_with_content) }
      it_should_behave_like "a fixity check failure preservation event"
    end
  end

end
