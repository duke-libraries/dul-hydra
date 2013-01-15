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
      obj.datastreams.each do |dsID, ds|
        ds.versions.each do |ds_version|
          linking_obj_id_val = ds_version.profile["dsCreateDate"].strftime("%Y-%m-%dT%H:%M:%S.%LZ")
          obj.preservationMetadata.find_by_xpath(".//oxns:event[oxns:eventType = \"fixity check\" and oxns:linkingObjectIdentifier/oxns:linkingObjectIdentifierType = \"datastreams/#{dsID}\" and oxns:linkingObjectIdentifier/oxns:linkingObjectIdentifierValue = \"#{linking_obj_id_val}\"]/oxns:eventOutcome").text.should == "PASSED"
        end
      end
    end
  end
end
