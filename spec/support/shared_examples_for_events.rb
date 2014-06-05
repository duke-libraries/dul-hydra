def mock_object(opts={})
  double("object", {create_date: "2014-01-01T01:01:01.000Z", modified_date: "2014-06-01T01:01:01.000Z"}.merge(opts))
end

shared_examples "a DulHydra software event" do
  it "should set software to the DulHydra version" do
    subject.valid?
    expect(subject.software).to eq "DulHydra #{DulHydra::VERSION}"
  end
end

shared_examples "a preservation-related event" do
  subject { described_class.new }
  it "should implement preservation-related behavior" do
    expect(subject).to be_a PreservationEvent
  end
  it "should have an event_type" do
    expect(subject.preservation_event_type).not_to be_nil
  end
  it "should have a PREMIS representation" do
    expect(subject).to respond_to :as_premis
    expect(subject).to respond_to :to_xml
  end
end

shared_examples "an event that reindexes its object after save" do
  it "should implement the reindexing concern" do
    expect(subject).to be_a DulHydra::Events::ReindexObjectAfterSave
  end
  context "when object is present" do
    let(:object) { mock_object }
    before do
      allow(subject).to receive(:object) { object }
    end
    it "should reindex its object after save" do
      expect(object).to receive(:update_index)
      subject.save(validate: false)
    end
  end
end

shared_examples "an event" do
  describe "validation" do
    it "should require presence of pid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:pid]).to include("can't be blank")
    end
    context "when the pid is set" do
      before do
        subject.pid = "test:123"
      end
      it "should require the referenced object to exist" do
        expect(subject).not_to be_valid
        expect(subject.errors).to have_key(:pid)
      end
    end
    it "should require a valid outcome" do
      subject.outcome = Event::SUCCESS
      subject.valid?
      expect(subject.errors.keys).not_to include :outcome
      subject.outcome = Event::FAILURE
      subject.valid?
      expect(subject.errors.keys).not_to include :outcome
      subject.outcome = "Some other value"
      subject.valid?
      expect(subject.errors[:outcome]).to include("\"Some other value\" is not a valid event outcome")
    end
  end

  describe "outcome setters and getters" do
    it "should encapsulate access" do
      subject.success!
      expect(subject.outcome).to eq Event::SUCCESS
      expect(subject).to be_success
      subject.failure!
      expect(subject.outcome).to eq Event::FAILURE
      expect(subject).to be_failure
    end
  end

  describe "defaults" do
    let(:object) { FactoryGirl.create(:test_model_omnibus) }
    before { allow(subject).to receive(:object) { object } }
    it "should set defaults before validation" do
      expect(subject).to receive(:set_defaults)
      subject.valid?
    end
    it "should set outcome to 'success'" do
      expect(subject.outcome).to be_nil
      subject.valid?
      expect(subject.outcome).to eq Event::SUCCESS
    end
    it "should set event_date_time if not present" do
      expect(subject.event_date_time).to be_nil
      expect { subject.valid? }.to change { subject.event_date_time }
    end
    context "when event_date_time value" do
      before { subject.event_date_time = Time.utc(2013) }
      it "should not overwrite the value" do
        expect { subject.valid? }.not_to change { subject.event_date_time }
      end
    end
    it "should set software if not present" do
      expect(subject.software).to be_nil
      subject.valid?
      expect(subject.software).to be_present
    end
  end

  describe "object getter" do
    subject { described_class.new(pid: "test:123") }
    let(:object) { mock_object }
    before { allow(ActiveFedora::Base).to receive(:find).with("test:123") { object } }
    it "should retrieve the object" do
      expect(subject.object).to eq object
    end
    it "should cache the object" do
      expect(ActiveFedora::Base).to receive(:find).with("test:123").once
      subject.object
      subject.object
    end
  end

  describe "object setter" do
    let(:object) { mock_object(pid: "test:123") }
    it "should set the event pid and object" do
      allow(object).to receive(:new_record?) { false }
      subject.object = object
      expect(subject.pid).to eq "test:123"
      expect(subject.object).to eq object
    end
    it "should raise an ArgumentError if object is a new record" do
      allow(object).to receive(:new_record?) { true }
      expect { subject.object = object }.to raise_error ArgumentError
    end
  end

  describe "object existence" do
    it "should be false if pid is nil" do
      expect(subject.object_exists?).to be_false
    end
    it "should be false if pid not found in repository" do
      subject.pid = "test:123"
      expect(subject.object_exists?).to be_false
    end
    it "should be true if object exists in repository" do
      allow(ActiveFedora::Base).to receive(:find).with("test:123") { mock_object }
      subject.pid = "test:123"
      expect(subject.object_exists?).to be_true
    end
    it "should be true if object instance variable is set" do
      obj = mock_object(pid: "test:123")
      allow(obj).to receive(:new_record?) { false }
      subject.object = obj
      expect(subject.object_exists?).to be_true
    end
  end

  describe "event_date_time string representation" do
    subject { described_class.new(event_date_time: Time.utc(2014, 6, 4, 11, 7, 35)) }
    it "should conform to the specified format" do
      expect(subject.event_date_time_s).to eq "2014-06-04T11:07:35.000Z"
    end
  end

  describe "rendering who/what performed the action" do
    let(:user) { FactoryGirl.build(:user) }
    it "should render the user if performed by a user" do
      subject.user = user
      expect(subject.performed_by).to eq user.to_s
    end
    it "should render 'SYSTEM' if not performed by a user" do
      expect(subject.performed_by).to eq "SYSTEM"
    end
  end
end
