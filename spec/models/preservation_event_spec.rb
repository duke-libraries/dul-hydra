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
      pe.should be_valid
      pe.event_date_time = nil
      pe.should_not be_valid
    end
    it "should validate event_type" do
      pe.should be_valid
      PreservationEvent::EVENT_TYPES.each do |t|
        pe.event_type = t
        pe.should be_valid
      end
      pe.event_type = "foo"
      pe.should_not be_valid
    end
    it "should validate event_outcome" do
      pe.should be_valid
      PreservationEvent::EVENT_OUTCOMES.each do |o|
        pe.event_outcome = o
        pe.should be_valid
      end
      pe.event_outcome = "foo"
      pe.should_not be_valid
    end
    it "should validate event_id_type" do
      pe.should be_valid
      PreservationEvent::EVENT_ID_TYPES.each do |t|
        pe.event_id_type = t
        pe.should be_valid
      end
      pe.event_id_type = "foo"
      pe.should_not be_valid
    end
    it "should validate event_id_value" do
      pe.should be_valid
      pe.event_id_value = nil
      pe.should_not be_valid
    end
    context "validate linking_object_id_type and linking_object_id_value" do
      it "should validate the presence of the linking_object_id_value if the linking_object_id_type is present" do
        pe.should be_valid
        pe.linking_object_id_type.should_not be_nil
        pe.linking_object_id_value.should_not be_nil
        pe.linking_object_id_value = nil
        pe.should_not be_valid
      end
      it "should validate the presence of the linking_object_id_type if the linking_object_id_value is present" do
        pe.should be_valid
        pe.linking_object_id_value.should_not be_nil
        pe.linking_object_id_type.should_not be_nil
        pe.linking_object_id_type = nil
        pe.should_not be_valid
      end
      it "should validate the existence and proper type of object referenced in the linking_object_id_value if the linking_object_id_type is 'object'" do
        pe.should be_valid
        pe.linking_object_id_type.should == PreservationEvent::OBJECT
        pe.for_object.should be_kind_of(DulHydra::Models::HasPreservationEvents)
        pe.linking_object_id_value = "foo:bar"
        pe.should_not be_valid
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

  describe ".events_for" do
    let(:obj) { FactoryGirl.create(:component_with_content) }
    let(:pe) { obj.fixity_check! }
    after { obj.destroy }
    context "object_or_pid" do
      it "should return preservation events associated with that object" do
        PreservationEvent.events_for(obj).should include(pe)
        PreservationEvent.events_for(obj.pid).should include(pe)
      end
    end
    context "filtered by event type" do
      it "should return only preservation events of that type associated with the object" do
        PreservationEvent.events_for(obj, PreservationEvent::FIXITY_CHECK).should include(pe)
        PreservationEvent.events_for(obj, PreservationEvent::INGESTION).should_not include(pe)
        PreservationEvent.events_for(obj, PreservationEvent::VALIDATION).should_not include(pe)
      end
    end
    context "invalid paramaters" do
      it "should raise a TypeError exception" do
        expect { PreservationEvent.events_for(1) }.to raise_error(TypeError)
        expect { PreservationEvent.events_for(obj, "foo") }.to raise_error(TypeError)
      end
    end
  end

end
