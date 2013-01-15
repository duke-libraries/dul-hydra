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
        next if dsID == "preservationMetadata"
        ds.versions.each do |ds_version|
          next if ds_version.profile.empty?
          puts ds_version.profile["dsVersionID"]
          linking_obj_id_val = dsID + "?asOfDateTime=" + ds_version.profile["dsCreateDate"].strftime("%Y-%m-%dT%H:%M:%S.%LZ")
          obj.preservationMetadata.find_by_xpath(".//oxns:event[oxns:eventType = \"fixity check\" and oxns:linkingObjectIdentifier/oxns:linkingObjectIdentifierType = \"datastream\" and oxns:linkingObjectIdentifier/oxns:linkingObjectIdentifierValue = \"#{linking_obj_id_val}\"]/oxns:eventOutcomeInformation/oxns:eventOutcome").text.should == "PASSED"
        end
      end
    end
  end
end
