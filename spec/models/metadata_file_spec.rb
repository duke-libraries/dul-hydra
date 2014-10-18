require 'spec_helper'
require 'rdf/isomorphic'

include RDF::Isomorphic

shared_examples "an invalid metadata file" do
  it "should not be valid" do
    expect(metadata_file).to_not be_valid
    expect(metadata_file.errors).to have_key(error_field)
  end  
end

shared_examples "a successful metadata file processing" do
  it "should create a batch with an appropriate UpdateBatchObject" do
    expect(@batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_READY)
    expect(@batch_object).to be_a(DulHydra::Batch::Models::UpdateBatchObject)
    expect(@datastream.name).to eq(Ddr::Datastreams::DESC_METADATA)
    expect(@datastream.operation).to eq(DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE)
    expect(@datastream.payload_type).to eq(DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES)
    expect(RDF::Reader.for(:ntriples).new(@datastream.payload)).to be_isomorphic_with(RDF::Reader.for(:ntriples).new(expected_md))
  end
end

describe MetadataFile, :type => :model, :metadata_file => true do
  
  context "validation" do

    let(:metadata_file) { FactoryGirl.create(:metadata_file_descmd_csv) }

    context "valid" do
      it "should have a valid factory" do
        expect(metadata_file).to be_valid
        expect(metadata_file.validate_data).to be_empty
      end
    end
    context "metadata file missing" do
      let(:error_field)  { :metadata }
      before { metadata_file.metadata = nil }
      it_behaves_like "an invalid metadata file"
    end
    context "profile missing" do
      let(:error_field)  { :profile }
      before { metadata_file.profile = nil }
      it_behaves_like "an invalid metadata file"
    end
    context "metadata file not parseable with profile" do
      before { metadata_file.update(:metadata => File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'mapped_tab.txt'))) }
      it "should have a parse error" do
        expect(metadata_file.validate_data.messages[:metadata].first).to include(I18n.t('batch.metadata_file.error.parse_error'))
      end
    end
    context "metadata file invalid attribute names"do
      context "invalid metadata header" do
        before { metadata_file.update(:metadata => File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'descmd_csv_invalid_column.csv'))) }
        it "should have an attribute name error" do
          expect(metadata_file.validate_data.messages[:metadata].first).to include("#{I18n.t('batch.metadata_file.error.attribute_name')}: invalid")
        end
      end
      context "invalid schema map target" do
        before do
          options =
            { 
              :csv => metadata_file.effective_options[:csv],
              :parse => metadata_file.effective_options[:parse],
              :schema_map => {
                "identifier" => "identifier",
                "title" => "title",
                "description" => "invalid",
                "subject" => "subject",
                "dateSubmitted" => "dateSubmitted"
              }
            }          
          allow_any_instance_of(MetadataFile).to receive(:effective_options).and_return(options)
        end
        it "should have an attribute name error" do
          expect(metadata_file.validate_data.messages[:metadata].first).to include("#{I18n.t('batch.metadata_file.error.mapped_attribute_name')}: description => invalid")
        end
      end
    end
  end

  context "successful processing", batch: true do

    let(:metadata_file) { FactoryGirl.build(:metadata_file) }

    let(:expected_md) do
      ds = Ddr::Datastreams::DescriptiveMetadataDatastream.new(nil, 'descMetadata')
      ds.title = "Updated Title"
      ds.identifier = "test12345"
      ds.description = 'This is some description; this is "some more" description.'
      ds.subject = [ "Alpha", "Beta", "Gamma" , "Delta", "Epsilon" ]
      ds.dateSubmitted = "2010-01-22"
      ds.arranger = "John Doe"
      ds.resource.dump :ntriples
    end

    before do
      allow_any_instance_of(MetadataFile).to receive_message_chain(:metadata, :path).and_return(delimited_file)
      allow_any_instance_of(MetadataFile).to receive(:effective_options).and_return(options)
      metadata_file.procezz
      @batch = DulHydra::Batch::Models::Batch.all.last
      @batch_object = @batch.batch_objects.first
      @datastream = @batch_object.batch_object_datastreams.first
    end

    context "cdm export metadata file" do
      let(:delimited_file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'mapped_tab.txt') }
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
            :repeatable_fields => [ "Subject-Keyword", "Subject-Topic" ]
          },
          :schema_map => {
            "Description" => "description",
            "Identifier-LocalID" => "identifier",
            "Subject-Keyword" => "subject",
            "Subject-Topic" => "subject",
            "Submission-Date" => "dateSubmitted",
            "Title" => "title",
            "Arranger" => "arranger"
          }
        }
      end      
      it_behaves_like "a successful metadata file processing"
    end
    
    context "desc metadata csv file" do
      let(:delimited_file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'descmd_csv.csv') }
      let(:options) do
        {
          :csv => {
            :col_sep => ",",
            :quote_char => '"',
            :headers => true
          },
          :parse => {
            :include_empty_fields => false,
            :repeating_fields_separator => ";",
            :repeatable_fields => [ "subject" ]
          }
        }
      end
      it_behaves_like "a successful metadata file processing"
    end
        
  end

end
