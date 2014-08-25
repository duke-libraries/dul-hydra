shared_examples "an access controllable object" do
  it "should have a rightsMetadata datastream" do
    expect(subject.datastreams.keys).to include("rightsMetadata")
    expect(subject.datastreams["rightsMetadata"]).to be_kind_of(Hydra::Datastream::RightsMetadata)
  end
end
