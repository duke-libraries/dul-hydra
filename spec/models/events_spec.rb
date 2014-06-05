require 'spec_helper'
require 'support/shared_examples_for_events'

describe Event, events: true do  
  it_behaves_like "an event"
  it_behaves_like "a DulHydra software event"
  describe "factory methods" do
    describe "build_event" do
      it "should return an new (unsaved) event of the type specified" do
        expect(described_class.build_event(:fixity_check)).to be_a FixityCheckEvent
        expect(described_class.build_event(:FixityCheck)).to be_a FixityCheckEvent
        expect(described_class.build_event("fixity_check")).to be_a FixityCheckEvent
        expect(described_class.build_event(:virus_check)).to be_a VirusCheckEvent
        expect(described_class.build_event(:VirusCheck)).to be_a VirusCheckEvent
        expect(described_class.build_event("virus_check")).to be_a VirusCheckEvent
        expect(described_class.build_event(:validation)).to be_a ValidationEvent
        expect(described_class.build_event(:Validation)).to be_a ValidationEvent
        expect(described_class.build_event("validation")).to be_a ValidationEvent
        expect(described_class.build_event(:ingestion)).to be_a IngestionEvent
        expect(described_class.build_event(:Ingestion)).to be_a IngestionEvent
        expect(described_class.build_event("ingestion")).to be_a IngestionEvent
        expect(described_class.build_event(:creation)).to be_a CreationEvent
        expect(described_class.build_event(:Creation)).to be_a CreationEvent
        expect(described_class.build_event("creation")).to be_a CreationEvent
        expect(described_class.build_event(:update)).to be_a UpdateEvent
        expect(described_class.build_event(:Update)).to be_a UpdateEvent
        expect(described_class.build_event("update")).to be_a UpdateEvent
      end
      it "should accept a block" do
        event = described_class.build_event(:ingestion) do |event|
          event.pid = "test:123"
        end
        expect(event).to be_a IngestionEvent
        expect(event.pid).to eq "test:123"
      end
    end
  end
end

describe UpdateEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Update"
  end
end

describe CreationEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Creation"
  end
  describe "defaults" do
    let(:item) { FactoryGirl.create(:item) }
    before do
      subject.object = item
      subject.valid?
    end
    it "should set a default summary" do
      expect(subject.summary).to eq "Item object created"
    end
    it "should set the default event_date_time to the object's create date" do
      expect(subject.event_date_time_s).to eq item.create_date
    end
  end
end

describe FixityCheckEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "an event that reindexes its object after save"
  it "should have a display type" do
    expect(subject.display_type).to eq "Fixity Check"
  end
  describe "defaults" do
    it "should set software to the Fedora repository version" do
      # Need a real object to get the Fedora repository profile
      subject.object = FactoryGirl.create(:test_model) 
      subject.valid?
      expect(subject.software).to match /^Fedora Repository \d\.\d\.\d$/
    end
    it "should set a default summary" do
      subject.valid?
      expect(subject.summary).to eq "Validation of datastream checksums"
    end
  end
end

describe VirusCheckEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "an event that reindexes its object after save"
  it "should have a display type" do
    expect(subject.display_type).to eq "Virus Check"
  end
  describe "defaults" do
    before { subject.valid? }
    it "should have a default summary" do
      expect(subject.summary).to eq "Content file scanned for viruses"
    end
    it "should set software to the antivirus software version" do
      expect(subject.software).to match /^ClamAV/
    end
  end
end

describe IngestionEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Ingestion"
  end
  describe "defaults" do
    let(:item) { FactoryGirl.create(:item) }
    before do
      subject.object = item
      subject.valid?
    end
    it "should set a default summary" do
      expect(subject.summary).to eq "Item object ingested"
    end
    it "should set the default event_date_time to the object's create date" do
      expect(subject.event_date_time_s).to eq item.create_date
    end
  end
end

describe ValidationEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Validation"
  end
end
