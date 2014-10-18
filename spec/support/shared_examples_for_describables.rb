shared_examples "a describable object" do
  let(:object) { described_class.new }
  context "having an identifier" do
    before do
      object.identifier = ["id001"]
      object.save(validate: false)
    end
    it "should be findable by identifier" do
      expect(described_class.find_by_identifier('id001')).to include object
    end
  end
  describe "#desc_metadata_terms" do
    it "should have a default value" do
      expect(object.desc_metadata_terms).to eq Ddr::Datastreams::DescriptiveMetadataDatastream.term_names
    end
    describe "arguments" do
      it "with fixed results" do
        expect(object.desc_metadata_terms(:dcterms)).to eq(Ddr::Metadata::Vocabulary.term_names(RDF::DC11) + (Ddr::Metadata::Vocabulary.term_names(RDF::DC) - Ddr::Metadata::Vocabulary.term_names(RDF::DC11)))
        expect(object.desc_metadata_terms(:dcterms)).to match_array Ddr::Metadata::Vocabulary.term_names(RDF::DC)
        expect(object.desc_metadata_terms(:duke)).to eq Ddr::Metadata::Vocabulary.term_names(Ddr::Metadata::DukeTerms)
        expect(object.desc_metadata_terms(:dcterms_elements11)).to eq Ddr::Metadata::Vocabulary.term_names(RDF::DC11)
        expect(object.desc_metadata_terms(:defined_attributes)).to match_array Ddr::Metadata::Vocabulary.term_names(RDF::DC11)
      end
      context "with variable results" do
        before do
          object.descMetadata.title = ["Object Title"]
          object.descMetadata.creator = ["Duke University Libraries"]
          object.descMetadata.identifier = ["id001"]
          object.save
        end
        it "should accept an :empty argument" do
          expect(object.desc_metadata_terms(:empty)).to eq(object.desc_metadata_terms - [:title, :creator, :identifier])
        end
        it "should accept a :present argument" do
          expect(object.desc_metadata_terms(:present)).to match_array [:title, :creator, :identifier]
        end
      end
    end
  end
  describe "#set_desc_metadata" do
    let(:term_values_hash) { object.desc_metadata_terms.each_with_object({}) {|t, memo| memo[t] = ["Value"]} }
    it "should set the descMetadata terms to the values of the matching keys in the hash" do
      object.desc_metadata_terms.each do |t|
        expect(object).to receive(:set_desc_metadata_values).with(t, ["Value"])
      end
      object.set_desc_metadata(term_values_hash)
    end
  end
  describe "#set_desc_metadata_values" do
    context "when values == nil" do
      it "should set the term to an empty value" do
        object.set_desc_metadata_values(:title, nil)
        expect(object.descMetadata.title).to be_empty
      end
    end
    context "when values is an array" do
      it "should reject empty values from the array" do
        object.set_desc_metadata_values(:title, ["Object Title", nil, "Alternative Title", ""])
        expect(object.descMetadata.title).to eq ["Object Title", "Alternative Title"]
      end
    end
  end
end
