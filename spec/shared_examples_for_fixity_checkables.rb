shared_examples "a fixity checkable object" do
  subject { described_class.new }
  it "should have a fixityCheck datastream" do
    subject.datastreams["fixityCheck"].should be_kind_of DulHydra::Datastreams::FixityCheckDatastream
  end
end
