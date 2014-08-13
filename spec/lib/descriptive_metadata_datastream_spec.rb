require 'spec_helper'
require 'helpers/metadata_helper'
require 'rdf/isomorphic'

include RDF::Isomorphic

describe DulHydra::Datastreams::DescriptiveMetadataDatastream do
  context "terminology" do
    subject { described_class.term_names }
    it "should have a term for each term name in the RDF::DC vocab" do
      expect(subject).to include(*DulHydra::Metadata::Vocabulary.term_names(RDF::DC))
    end
    it "should have a term for each term name in the DukeTerms vocab" do
      expect(subject).to include(*DulHydra::Metadata::Vocabulary.term_names(DukeTerms))
    end
  end
  context "properties" do
    subject { described_class.properties.map { |prop| prop[1].predicate } }
    it "should include all the RDF::DC predicates" do
      expect(subject).to include(*DulHydra::Metadata::Vocabulary.property_terms(RDF::DC))
    end
    it "should include all the DukeTerms predicates" do
      expect(subject).to include(*DulHydra::Metadata::Vocabulary.property_terms(DukeTerms))
    end
  end
  context "raw content" do
    let(:ds) { described_class.new(nil, 'descMetadata') }
    before do
      content = sample_metadata_triples(ds.rdf_subject.to_s)
      ds.content = content
      ds.resource.set_subject!(ds.rdf_subject)
    end
    it "should retrieve the content using the terminology" do
      expect(ds.title).to eq(["Sample title"])
      expect(ds.creator).to eq(["Sample, Example"])
      expect(ds.type).to eq(["Image", "Still Image"])
      expect(ds.spatial).to eq(["Durham County (NC)", "Durham (NC)"])
      expect(ds.date).to eq(["1981-01"])
      expect(ds.rights).to eq(["The copyright for these materials is unknown."])
      expect(ds.print_number).to eq(["12-345-6"])
      expect(ds.series).to eq(["Photographic Materials Series"])
      expect(ds.subseries).to eq(["Local Court House"])
    end
  end
  context "using the terminology setters" do
    let(:ds) { described_class.new(nil, 'descMetadata') }
    let(:content) { sample_metadata_triples(ds.rdf_subject.to_s) }
    before do
      ds.title = "Sample title"
      ds.creator = "Sample, Example"
      ds.type = ["Image", "Still Image"]
      ds.spatial = ["Durham County (NC)", "Durham (NC)"]
      ds.date = "1981-01"
      ds.rights = "The copyright for these materials is unknown."
      ds.print_number = "12-345-6"
      ds.series = "Photographic Materials Series"
      ds.subseries = "Local Court House"
    end
    it "should create equivalent RDF graph to that based on the raw version" do
      expect(ds.resource).to be_isomorphic_with(RDF::Reader.for(:ntriples).new(content))
    end
  end
  context "solrization" do
    let(:ds) { described_class.new(nil, 'descMetadata') }
    subject { ds.to_solr }
    before do
      content = sample_metadata_triples(ds.rdf_subject.to_s)
      ds.content = content
      ds.resource.set_subject!(ds.rdf_subject)
    end
    it "should create fields for all the terms that have non-empty values" do
      expect(subject).to include("title_tesim" => ["Sample title"])
      expect(subject).to include("creator_tesim" => ["Sample, Example"])
      expect(subject).to include("type_tesim" => ["Image", "Still Image"])
      expect(subject).to include("spatial_tesim" => ["Durham County (NC)", "Durham (NC)"])
      expect(subject).to include("date_tesim" => ["1981-01"])
      expect(subject).to include("rights_tesim" => ["The copyright for these materials is unknown."])
      expect(subject).to include("print_number_tesim" => ["12-345-6"])
      expect(subject).to include("series_tesim" => ["Photographic Materials Series"])
      expect(subject).to include("subseries_tesim" => ["Local Court House"])
    end
  end
end
