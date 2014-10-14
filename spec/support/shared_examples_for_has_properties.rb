shared_examples "an object that has properties" do
  it "should have a properties datastream" do
    expect(subject.datastreams.keys).to include(Ddr::Datastreams::PROPERTIES)
  end
end
