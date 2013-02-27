require 'spec_helper'

shared_examples "an ingested batch" do

  let(:expected_identifiers) { [ ["id001"], ["id002", "id003"], ["id004"] ] }
  let(:expected_label) { "Manifest Label" }
  let(:expected_desc_metadata_label) { "Descriptive Metadata for this object" }

  it "should be in the repository with a descMetadata datastream" do
    found_identifiers = []
    object_type.find_each do |object|
      object.admin_policy.should eq(admin_policy)
      object.label.should eq(expected_label)
      object.descMetadata.label.should eq(expected_desc_metadata_label)
      object.descMetadata.content.should_not be_empty
      found_identifiers << object.identifier
    end
    found_identifiers.sort.should eq(expected_identifiers.sort)
  end

  it "should have the object PID's in the master file" do
    master.xpath("/objects/object").each do |object|
      identifier = object.xpath("identifier").first.content
      object.xpath("pid").should_not be_empty
      pid = object.xpath("pid").first.content
      repo_object = object_type.find(pid)
      repo_object.identifier.should include(identifier)
    end
  end

  it "should have an ingestion preservation event for each object" do
    object_type.find_each do |object|
      events = object.preservation_events
      ingestion_events = []
      events.each do |event|
        if event.event_type == PreservationEvent::INGESTION
          ingestion_events << event
        end
      end
      ingestion_events.size.should eq(1)
      ingestion_event = ingestion_events.first
      DateTime.strptime(ingestion_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
      DateTime.strptime(ingestion_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
      ingestion_event.event_outcome.should == PreservationEvent::SUCCESS
      ingestion_event.linking_object_id_type.should eq(PreservationEvent::OBJECT)
      ingestion_event.linking_object_id_value.should eq(object.internal_uri)
      ingestion_event.event_detail.should include("Identifier(s): #{object.identifier.flatten.join(',')}")
    end
  end

  it "should have a ingestion log file" do
    log_file.should match("DulHydra version #{DulHydra::VERSION}")
    log_file.should match("Manifest: #{manifest}")
    object_type.find_each do |object|
      log_file.should match("Ingested #{object_type.to_s} #{object.identifier.first} into #{object.pid}")
    end
  end

end

shared_examples "an ingested batch with files" do

  let(:expected_content_label) { "Content file for this object" }
  let(:expected_contentdm_label) { "CONTENTdm Data for this object" }
  let(:expected_digitization_guide_label) { "Digitization Guide Data for this object" }
  let(:expected_dpc_metadata_label) { "DPC Metadata Data for this object" }
  let(:expected_fmp_export_label) { "FileMakerPro Export Data for this object" }
  let(:expected_jhove_label) { "JHOVE Data for this object" }
  let(:expected_marc_xml_label) { "Aleph MarcXML Data for this object" }
  let(:expected_tripod_mets_label) { "Tripod METS Data for this object" }

  it "should have the appropriate datastreams" do
    object_type.find_each do |object|
      object.content.label.should eq(expected_content_label)
      FileUtils.compare_stream(StringIO.new(object.content.content), StringIO.new(tif_file)).should be_true
      object.contentdm.label.should eq(expected_contentdm_label)
      FileUtils.compare_stream(StringIO.new(object.contentdm.content), StringIO.new(xml_file)).should be_true
      object.digitizationGuide.label.should eq(expected_digitization_guide_label)
      FileUtils.compare_stream(StringIO.new(object.digitizationGuide.content), StringIO.new(xls_file)).should be_true
      object.dpcMetadata.label.should eq(expected_dpc_metadata_label)
      FileUtils.compare_stream(StringIO.new(object.dpcMetadata.content), StringIO.new(xml_file)).should be_true
      object.fmpExport.label.should eq(expected_fmp_export_label)
      FileUtils.compare_stream(StringIO.new(object.fmpExport.content), StringIO.new(xml_file)).should be_true
      object.jhove.label.should eq(expected_jhove_label)
      FileUtils.compare_stream(StringIO.new(object.jhove.content), StringIO.new(xml_file)).should be_true
      object.marcXML.label.should eq(expected_marc_xml_label)
      FileUtils.compare_stream(StringIO.new(object.marcXML.content), StringIO.new(xml_file)).should be_true
      object.tripodMets.label.should eq(expected_tripod_mets_label)
      FileUtils.compare_stream(StringIO.new(object.tripodMets.content), StringIO.new(xml_file)).should be_true
    end
  end

end

shared_examples "a child object" do

  it "should have the correct parent object" do
    object_type.find_each do |object|
      object.parent.should eq(parents[object.identifier.first])
    end
  end

end

shared_examples "a target object" do
  it "should be associated with a collection" do
    Target.find_each do |target|
      target.collection.should eq(collection)
    end
  end
end

shared_examples "a validated ingest" do
  it "should have an ingest validation log file" do
    log_file.should_not be_empty
    log_file.should match("DulHydra version #{DulHydra::VERSION}")
    log_file.should match("Manifest: #{manifest}")
    results.each do |key, value|
      log_file.should match("Validated #{object_type.to_s} #{key} in .*...#{value}")
    end
    log_file.should match("Validated #{results.size} object\\(s\\)")
  end
end

shared_examples "a validated ingest with repository objects" do
  let(:outcomes) { Hash[ "PASS" => PreservationEvent::SUCCESS, "FAIL" => PreservationEvent::FAILURE ] }
  it "should have ingest validation preservation events" do
    object_type.find_each do |object|
      events = object.preservation_events
      validation_events = []
      events.each do |event|
        if event.event_type == PreservationEvent::VALIDATION
          validation_events << event
        end
      end
      validation_events.size.should eq(1)
      validation_event = validation_events.first
      DateTime.strptime(validation_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
      DateTime.strptime(validation_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
      validation_event.event_outcome.should == outcomes[results[object.identifier.first]]
      validation_event.linking_object_id_type.should eq(PreservationEvent::OBJECT)
      validation_event.linking_object_id_value.should eq(object.internal_uri)
      validation_event.event_detail.should include("Identifier(s): #{object.identifier.flatten.join(',')}")
      case outcomes[results[object.identifier.first]]
      when PreservationEvent::SUCCESS
        validation_event.event_detail.should include("PASS")
        validation_event.event_detail.should_not include("FAIL")
        validation_event.event_detail.should include("VALIDATES")
      when PreservationEvent::FAILURE
        validation_event.event_detail.should include("FAIL")
        validation_event.event_detail.should include("DOES NOT VALIDATE")
        if !details.blank?
          validation_event.event_detail.should include(details[object.identifier.first])
        end
      end
    end
  end
end

shared_examples "a validated ingest with content" do
  let(:outcomes) { Hash[ "PASS" => PreservationEvent::SUCCESS, "FAIL" => PreservationEvent::FAILURE ] }
  it "should have fixity check preservation events" do
    object_type.find_each do |object|
      fixity_check_events = object.fixity_checks
      fixity_check_events.to_a.size.should eq(1)
      fixity_check_event = fixity_check_events.first
      DateTime.strptime(fixity_check_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should < Time.now
      DateTime.strptime(fixity_check_event.event_date_time, PreservationEvent::DATE_TIME_FORMAT).should > 3.minutes.ago
      fixity_check_event.event_outcome.should == outcomes[results[object.identifier.first]]
    end
  end
end
