require 'spec_helper'
require 'support/shared_examples_for_events'

describe Event, events: true do  
  it_behaves_like "an event"
  it_behaves_like "a DulHydra software event"
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
      expect(subject.software).to match /^Fedora Repository \d\.\d\.\d$/
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
end

describe IngestionEvent, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Ingestion"
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
