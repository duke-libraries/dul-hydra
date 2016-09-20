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
    expect(@batch.status).to eq(Ddr::Batch::Batch::STATUS_READY)
    expect(@batch_object).to be_a(Ddr::Batch::UpdateBatchObject)
    expect(@attributes.size).to eq(20)
    # Attribute 'clear' entries
    clears =  @attributes.select { |att| att.operation == Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR }
    expect(clears.size).to eq(8)
    adm_clears = clears.select { |att| att.datastream == Ddr::Datastreams::ADMIN_METADATA }
    desc_clears = clears.select { |att| att.datastream == Ddr::Datastreams::DESC_METADATA }
    expect(adm_clears.size).to eq(3)
    expect(desc_clears.size).to eq(5)
    expect(adm_clears.map { |att| att.name }).to match_array([ 'local_id', 'ead_id', 'license' ])
    expect(desc_clears.map { |att| att.name }).to match_array([ 'title', 'description', 'subject', 'dateSubmitted', 'arranger' ])
    # Attribute 'add' entries
    adds = @attributes.select { |att| att.operation == Ddr::Batch::BatchObjectAttribute::OPERATION_ADD }
    expect(adds.size).to eq(12)
    adm_adds = adds.select { |att| att.datastream == Ddr::Datastreams::ADMIN_METADATA }
    desc_adds = adds.select { |att| att.datastream == Ddr::Datastreams::DESC_METADATA }
    expect(adm_adds.size).to eq(3)
    expect(desc_adds.size).to eq(9)
    expect(adm_adds.map { |att| att.name }).to match_array([ 'local_id', 'ead_id', 'license' ])
    expect(desc_adds.map { |att| att.name }).to match_array([ 'title', 'description', 'subject', 'subject', 'subject', 'subject', 'subject', 'dateSubmitted', 'arranger' ])
    actual_md = {}
    adds.each do |att|
      expect(att.value_type).to eq(Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING)
      actual_md[att.name] ||= []
      actual_md[att.name] << att.value
    end
    expect(actual_md.keys).to match_array(expected_md.keys)
    actual_md.each do |key, value|
      expect(Array(expected_md[key])).to match_array(value)
    end
  end
end

describe MetadataFile, :type => :model, :metadata_file => true do

  context "validation" do

    let(:metadata_file) { FactoryGirl.create(:metadata_file_descmd_csv) }

    context "valid" do
      before do
        allow(Ddr::Models::AdminSet).to receive(:keys) { [ 'dc' ] }
        allow(Ddr::Models::License).to receive(:keys) { [ 'https://creativecommons.org/licenses/by/4.0/' ] }
      end
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
      before { metadata_file.update(:metadata => File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'metadata_csv_malformed.csv'))) }
      it "should have a parse error" do
        expect(metadata_file.validate_data.messages[:metadata].first).to include(I18n.t('batch.metadata_file.error.parse_error'))
      end
    end
    context "metadata file invalid attribute names"do
      context "invalid metadata header" do
        before { metadata_file.update(:metadata => File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'metadata_csv_invalid_column.csv'))) }
        it "should have an attribute name error" do
          expect(metadata_file.validate_data.messages[:metadata]).to include("#{I18n.t('batch.metadata_file.error.attribute_name')}: invalid")
        end
      end
    end
    context "metadata file invalid controlled vocabulary value" do
      before do
        allow(Ddr::Models::AdminSet).to receive(:keys) { [ 'dc', 'dvs' ] }
        allow(Ddr::Models::License).to receive(:keys) { [ 'https://creativecommons.org/publicdomain/zero/1.0/' ] }
        metadata_file.update(:metadata => File.new(Rails.root.join('spec', 'fixtures', 'batch_update', 'metadata_csv_invalid_value.csv')))
      end
      it "should have an attribute value error" do
        expect(metadata_file.validate_data.messages[:metadata]).to include("#{I18n.t('batch.metadata_file.error.attribute_value')}: admin_set -> foo")
      end
    end
  end

  context "successful processing", batch: true do

    let(:metadata_file) { FactoryGirl.build(:metadata_file) }

    let(:expected_md) do
      { "local_id" => "test12345",
        "title" => [ "Updated Title" ],
        "description" => [ 'This is some description; this is "some more" description.' ],
        "subject" => [ "Alpha", "Beta", "Gamma" , "Delta", "Epsilon" ],
        "dateSubmitted" => [ "2010-01-22" ],
        "arranger" => [ "John Doe"  ],
        "ead_id" => "abcdef",
        "license" => "https://creativecommons.org/licenses/by/4.0/" }
    end

    before do
      allow_any_instance_of(MetadataFile).to receive_message_chain(:metadata, :path).and_return(delimited_file)
      allow_any_instance_of(MetadataFile).to receive(:effective_options).and_return(options)
      metadata_file.procezz
      @batch = Ddr::Batch::Batch.all.last
      @batch_object = @batch.batch_objects.first
      @attributes = @batch_object.batch_object_attributes
    end

    context "desc metadata csv file" do
      let(:delimited_file) { File.join(Rails.root, 'spec', 'fixtures', 'batch_update', 'metadata_csv.csv') }
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
