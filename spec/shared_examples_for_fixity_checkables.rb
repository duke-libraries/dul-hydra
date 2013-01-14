shared_examples "a fixity checkable object" do
  context "a new object" do
    subject { described_class.new }
    it "should have a preservationMetadata datastream" do
      subject.datastreams["preservationMetadata"].should be_kind_of DulHydra::Datastreams::PreservationMetadataDatastream
    end
  end
  context "fixity check" do
    before { obj.check_fixity! }
    after { obj.delete }
    let(:obj) { described_class.create }
    it "should have a preservation event for each datastream version" do
      obj.datastreams.each_value do |ds|
        ds.versions.each do |ds_version|
          ds_fixity_checks = obj.datastream_fixity_checks(ds_version)
          ds_fixity_checks.length.should == 1
          ds_fixity_checks[0][:eventOutcome].should == "PASSED"
        end
      end
    end
  end
end
