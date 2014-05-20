require 'spec_helper'

describe DulHydra::Datastreams::DescriptiveMetadataDatastream do
  let(:content) do
    <<-EOS
      <dc xmlns:dcterms="http://purl.org/dc/terms/" xmlns:duke="http://library.duke.edu/metadata/terms">
        <dcterms:title>Mother and son waiting outside court room, 1981 Jan. (Understandings)</dcterms:title>
        <dcterms:creator>Kwilecki, Paul, 1928-</dcterms:creator>
        <dcterms:type>black-and-white photographs</dcterms:type>
        <dcterms:type>documentary photographs</dcterms:type>
        <dcterms:type>photographs</dcterms:type>
        <dcterms:type>Image</dcterms:type>
        <dcterms:type>Still Image</dcterms:type>
        <dcterms:spatial>Georgia</dcterms:spatial>
        <dcterms:spatial>Decatur County (Ga.)</dcterms:spatial>
        <dcterms:spatial>Bainbridge (Ga.)</dcterms:spatial>
        <dcterms:provenance>The Paul Kwilecki Photographs and Papers were purchased by the Rare Book, Manuscript, and Special Collections Library from 1991 to 2010.</dcterms:provenance>
        <dcterms:extent>11 x 14 in.</dcterms:extent>
        <dcterms:date>1981-01</dcterms:date>
        <dcterms:temporal>1981-01</dcterms:temporal>
        <dcterms:rights>The copyright in the materials included in the Paul Kwilecki Photographs and Papers collection are owned by the photographer's heirs. The photographs are made available by Duke University Libraries, with permission, for the purpose of research, teaching, and private study. For these purposes users may reproduce single copies of the images from this website without prior permission, on the condition that proper attribution is provided on all such copies. For all other uses, and especially for any proposed commercial uses, researchers must contact the Library to request permission.</dcterms:rights>
        <duke:print_number>12-181-3</duke:print_number>
        <duke:box_number>Box PHO 1</duke:box_number>
        <duke:series>Photographic Materials Series</duke:series>
        <duke:subseries>Decatur County Court House</duke:subseries>
     </dc>
EOS
  end
  context "terminology" do
    subject { described_class.terminology.terms.reject {|key, term| term.is_root_term?}.keys }
    it "should have a term for each term name in the DCTerms vocab" do
      expect(subject).to include(*DulHydra::Metadata::DCTerms.term_names)
    end
    it "should have a term for each term name in the DukeTerms vocab" do
      expect(subject).to include(*DulHydra::Metadata::DukeTerms.term_names)
    end
  end
  context "xml template" do
    subject { described_class.xml_template }
    it "should have the DCTerms namespace" do
      expect(subject.namespaces).to include("xmlns:#{DulHydra::Metadata::DCTerms.namespace_prefix}" => DulHydra::Metadata::DCTerms.xmlns)
    end
    it "should have the DukeTerms namespace" do
      expect(subject.namespaces).to include("xmlns:#{DulHydra::Metadata::DukeTerms.namespace_prefix}" => DulHydra::Metadata::DukeTerms.xmlns)
    end
  end
  context "raw content" do
    let(:ds) { described_class.new(nil, 'descMetadata') }
    before { ds.content = content }
    it "should retrieve the content using the terminology" do
      expect(ds.title).to eq(["Mother and son waiting outside court room, 1981 Jan. (Understandings)"])
      expect(ds.creator).to eq(["Kwilecki, Paul, 1928-"])
      expect(ds.type).to eq(["black-and-white photographs", "documentary photographs", "photographs", "Image", "Still Image"])
      expect(ds.spatial).to eq(["Georgia", "Decatur County (Ga.)", "Bainbridge (Ga.)"])
      expect(ds.provenance).to eq(["The Paul Kwilecki Photographs and Papers were purchased by the Rare Book, Manuscript, and Special Collections Library from 1991 to 2010."])
      expect(ds.extent).to eq(["11 x 14 in."])
      expect(ds.date).to eq(["1981-01"])
      expect(ds.temporal).to eq(["1981-01"])
      expect(ds.rights).to eq(["The copyright in the materials included in the Paul Kwilecki Photographs and Papers collection are owned by the photographer's heirs. The photographs are made available by Duke University Libraries, with permission, for the purpose of research, teaching, and private study. For these purposes users may reproduce single copies of the images from this website without prior permission, on the condition that proper attribution is provided on all such copies. For all other uses, and especially for any proposed commercial uses, researchers must contact the Library to request permission."])
      expect(ds.print_number).to eq(["12-181-3"])
      expect(ds.box_number).to eq(["Box PHO 1"])
      expect(ds.series).to eq(["Photographic Materials Series"])
      expect(ds.subseries).to eq(["Decatur County Court House"])
    end
  end
  context "using the terminology setters" do
    let(:ds) { described_class.new(nil, 'descMetadata') }
    before do
      ds.title = "Mother and son waiting outside court room, 1981 Jan. (Understandings)"
      ds.creator = "Kwilecki, Paul, 1928-"
      ds.type = ["black-and-white photographs", "documentary photographs", "photographs", "Image", "Still Image"]
      ds.spatial = ["Georgia", "Decatur County (Ga.)", "Bainbridge (Ga.)"]
      ds.provenance = "The Paul Kwilecki Photographs and Papers were purchased by the Rare Book, Manuscript, and Special Collections Library from 1991 to 2010."
      ds.extent = "11 x 14 in."
      ds.date = "1981-01"
      ds.temporal = "1981-01"
      ds.rights = "The copyright in the materials included in the Paul Kwilecki Photographs and Papers collection are owned by the photographer's heirs. The photographs are made available by Duke University Libraries, with permission, for the purpose of research, teaching, and private study. For these purposes users may reproduce single copies of the images from this website without prior permission, on the condition that proper attribution is provided on all such copies. For all other uses, and especially for any proposed commercial uses, researchers must contact the Library to request permission."
      ds.print_number = "12-181-3"
      ds.box_number = "Box PHO 1"
      ds.series = "Photographic Materials Series"
      ds.subseries = "Decatur County Court House"
    end
    it "should create equivalent XML to the raw version" do
      expect(ds.ng_xml).to be_equivalent_to(Nokogiri::XML(content))
    end
  end
  context "solrization" do
    let(:ds) { described_class.new(nil, 'descMetadata') }
    subject { ds.to_solr }
    before { ds.content = content }
    it "should create fields for all the terms that have non-empty values" do
      expect(subject).to include("title_tesim" => ["Mother and son waiting outside court room, 1981 Jan. (Understandings)"])
      expect(subject).to include("creator_tesim" => ["Kwilecki, Paul, 1928-"])
      expect(subject).to include("type_tesim" => ["black-and-white photographs", "documentary photographs", "photographs", "Image", "Still Image"])
      expect(subject).to include("spatial_tesim" => ["Georgia", "Decatur County (Ga.)", "Bainbridge (Ga.)"])
      expect(subject).to include("provenance_tesim" => ["The Paul Kwilecki Photographs and Papers were purchased by the Rare Book, Manuscript, and Special Collections Library from 1991 to 2010."])
      expect(subject).to include("extent_tesim" => ["11 x 14 in."])
      expect(subject).to include("date_tesim" => ["1981-01"])
      expect(subject).to include("temporal_tesim" => ["1981-01"])
      expect(subject).to include("rights_tesim" => ["The copyright in the materials included in the Paul Kwilecki Photographs and Papers collection are owned by the photographer's heirs. The photographs are made available by Duke University Libraries, with permission, for the purpose of research, teaching, and private study. For these purposes users may reproduce single copies of the images from this website without prior permission, on the condition that proper attribution is provided on all such copies. For all other uses, and especially for any proposed commercial uses, researchers must contact the Library to request permission."])
      expect(subject).to include("print_number_tesim" => ["12-181-3"])
      expect(subject).to include("box_number_tesim" => ["Box PHO 1"])
      expect(subject).to include("series_tesim" => ["Photographic Materials Series"])
      expect(subject).to include("subseries_tesim" => ["Decatur County Court House"])
    end
  end
end
