shared_examples "an access controllable object" do
  it "should have a rightsMetadata datastream" do
    subject.datastreams.keys.should include("rightsMetadata")
    subject.datastreams["rightsMetadata"].should be_kind_of(Hydra::Datastream::RightsMetadata)
  end
end
