require 'spec_helper'

def create_pe(obj, type)
  PreservationEvent.new.tap do |pe|
    pe.for_object = obj
    pe.event_type = type
    pe.event_outcome = PreservationEvent::SUCCESS
    pe.event_detail = "Information about the event"
    pe.event_outcome_detail_note = "Detailed information about the outcome"
    pe.save!
  end
end

def run_conversion
  File.readlines(File.join(Rails.root, 'db', 'sql', 'PreservationEventsToEvents.sql')).each do |sql|
    Event.connection.execute(sql)    
  end
end

shared_examples "an event converted from a preservation event" do
  it "should be persisted" do
    expect(subject).to be_persisted
  end
  it "should be valid" do
    expect(subject).to be_valid
  end
  it "should be success" do
    expect(subject).to be_success
  end
  it "should have a summary" do
    expect(subject.summary).to eq "Information about the event"
  end
  it "should have a detail" do
    expect(subject.detail).to eq "Detailed information about the outcome"
  end
end

describe PreservationEvent do
  describe "conversion to events" do
    let(:obj) { FactoryGirl.create(:test_model) }
    before(:each) do
      create_pe(obj, type)
      run_conversion
    end
    context "fixity check" do
      let(:type) { PreservationEvent::FIXITY_CHECK }
      subject { FixityCheckEvent.first }
      it_should_behave_like "an event converted from a preservation event"
    end
    context "validation" do
      let(:type) { PreservationEvent::VALIDATION }
      subject { ValidationEvent.first }
      it_should_behave_like "an event converted from a preservation event"
    end
    context "ingestion" do
      let(:type) { PreservationEvent::INGESTION }
      subject { IngestionEvent.first }
      it_should_behave_like "an event converted from a preservation event"
    end
  end
end
