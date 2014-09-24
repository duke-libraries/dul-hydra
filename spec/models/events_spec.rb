require 'spec_helper'
require 'support/shared_examples_for_events'

describe Event, type: :model, events: true do  
  it_behaves_like "an event"
  it_behaves_like "a DulHydra software event"
end

describe UpdateEvent, type: :model, events: true do
  it_behaves_like "an event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Update"
  end
end

describe CreationEvent, type: :model, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Creation"
  end
end

describe FixityCheckEvent, type: :model, events: true do
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
  describe "subscriptions" do
    let!(:obj) { FactoryGirl.create(:test_model) }
    it "should subscribe to fixity checks" do
      expect { FixityCheck.execute(obj) }.to change { obj.fixity_checks.count }.by 1
    end
  end
end

describe VirusCheckEvent, type: :model, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "an event that reindexes its object after save"
  it "should have a display type" do
    expect(subject.display_type).to eq "Virus Check"
  end
end

describe IngestionEvent, type: :model, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Ingestion"
  end
end

describe ValidationEvent, type: :model, events: true do
  it_behaves_like "an event"
  it_behaves_like "a preservation-related event"
  it_behaves_like "a DulHydra software event"
  it "should have a display type" do
    expect(subject.display_type).to eq "Validation"
  end
end
