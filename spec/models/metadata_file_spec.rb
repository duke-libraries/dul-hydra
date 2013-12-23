require 'spec_helper'

describe MetadataFile do

  context "successful processing" do
    
    let(:identifier) { repo_object.identifier.first }
    let(:delimited_file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'qdc_tabbed.txt') }
    let(:options) do
      {
        :csv => {
          :col_sep => "\t",
          :quote_char => '`',
          :headers => true
        },
        :parse => {
          :include_empty_fields => false,
          :repeating_fields_separator => ";",
          :repeatable_fields => [ "subject" ]
        }
      }
    end
    let(:metadata_file) { MetadataFile.create }
    let(:expected_qdc) do
      ds = ActiveFedora::QualifiedDublinCoreDatastream.new
      ds.title = "Updated Title"
      ds.identifier = "test12345"
      ds.description = "This is some description; this is some more description."
      ds.subject = [ "Alpha", "Beta", "Gamma" ]
      ds.content
    end
    
    before do
      MetadataFile.any_instance.stub_chain(:metadata, :path).and_return(delimited_file)
      MetadataFile.any_instance.stub(:effective_options).and_return(options)
      metadata_file.procezz
      @batch = DulHydra::Batch::Models::Batch.all.last
      @batch_object = @batch.batch_objects.first
      @datastream = @batch_object.batch_object_datastreams.first
    end
    
    after do
      metadata_file.destroy
      @batch.destroy
    end
    
    it "should create a batch with an appropriate UpdateBatchObject" do
      expect(@batch_object).to be_a(DulHydra::Batch::Models::UpdateBatchObject)
      expect(@datastream.name).to eq(DulHydra::Datastreams::DESC_METADATA)
      expect(@datastream.operation).to eq(DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE)
      expect(@datastream.payload_type).to eq(DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES)
      expect(Nokogiri::XML(@datastream.payload)).to be_equivalent_to(Nokogiri::XML(expected_qdc))
    end
    
  end

end