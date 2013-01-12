shared_examples "a fixity checkable object" do
  subject { described_class.new }
  it "should have a preservationMetadata datastream" do
    subject.datastreams["preservationMetadata"].should be_kind_of DulHydra::Datastreams::PreservationMetadataDatastream
  end
end
