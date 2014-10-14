require 'spec_helper'
require 'helpers/metadata_helper'
require 'rdf/isomorphic'

include RDF::Isomorphic

module DulHydra::Batch::Scripts

  describe MetadataFolderProcessor do

    let(:folder) { "/tmp" }
    
    describe "#initialize" do
      context "folder" do
        context "no folder" do
          it "should raise an exception" do
            expect { described_class.new }.to raise_error
          end
        end
      end
      context "collection" do
        let(:collection) { FactoryGirl.create(:collection) }
        context "pid" do
          describe '#collection attribute should contain the appropriate collection' do
            subject { super().collection attribute is_expected.to contain the appropriate collection }
            it do
            expect(described_class.new({ folder: folder, collection: collection.pid }).collection).to eq(collection)
          end
          end          
        end
        context "object" do
          describe '#collection attribute should contain the appropriate collection' do
            subject { super().collection attribute is_expected.to contain the appropriate collection }
            it do
            expect(described_class.new({ folder: folder, collection: collection }).collection).to eq(collection)
          end
          end          
        end
      end
      context "user" do
        let(:user) { FactoryGirl.create(:user) }
        context "user key" do
          describe '#user attribute should contain the appropriate user' do
            subject { super().user attribute is_expected.to contain the appropriate user }
            it do
            expect(described_class.new({ folder: folder, user: user.user_key }).user).to eq(user)
          end
          end          
        end
        context "object" do
          describe '#user attribute should contain the appropriate user' do
            subject { super().user attribute is_expected.to contain the appropriate user }
            it do
            expect(described_class.new({ folder: folder, user: user }).user).to eq(user)
          end
          end          
        end
      end
      context "logger" do
        it "should have a logger" do
          expect(described_class.new({ folder: folder }).logger).to_not be_nil
        end
      end
    end

    describe "#scan" do
      let(:mfp) { described_class.new({ folder: folder }) }
      let(:object) { FactoryGirl.create(:test_model) }
      before do
        object.update_attributes(identifier: [ "efghi01003"] )
        allow(Dir).to receive(:foreach).and_call_original
        allow(Dir).to receive(:foreach).with(folder).and_return(["md.xml"].each)
        allow(File).to receive(:directory?).and_call_original
        allow(File).to receive(:directory?).with(File.join(folder, "md.xml")).and_return(false)
        allow(File).to receive(:read).and_call_original
      end
      context "no warnings or errors" do
        let(:subject_string) { "<#{ActiveFedora::Rdf::ObjectResource.base_uri}#{object.pid}>" }
        let(:expected_triples) do
          "#{subject_string} <http://purl.org/dc/terms/identifier> \"efghi01003\" .\n".concat(sample_metadata_triples(subject_string))
        end
        before do
          allow(File).to receive(:read).with(File.join(folder, "md.xml")).and_return(sample_mets_xml)
        end
        it "should populate the scanner hash appropriately" do
          mfp.scan
          expect(mfp.scanner.keys).to eq( [ File.join(folder, "md.xml") ] )
          dmdsecs = mfp.scanner[File.join(folder, "md.xml")]
          expect(dmdsecs.keys).to eq( [ "abcd_efghi01003" ] )
          dmdsec = dmdsecs["abcd_efghi01003"]
          expect(dmdsec[:id]).to eq("efghi01003")
          expect(dmdsec[:pid]).to eq(object.pid)
          expect(RDF::Reader.for(:ntriples).new(dmdsec[:md])).to be_isomorphic_with(RDF::Reader.for(:ntriples).new(expected_triples))
        end
        it "should not report any warnings or errors" do
          expect(mfp.logger).to receive(:info).exactly(2).times
          expect(mfp.logger).to_not receive(:warn)
          expect(mfp.logger).to_not receive(:error)
          mfp.scan
          expect(mfp.report).to include("0 WARNINGS and 0 ERRORS")
        end
      end
      context "element has attribute" do
        before { allow(File).to receive(:read).with(File.join(folder, "md.xml")).and_return(sample_mets_with_element_attribute) }
        it "should report a warning" do
          expect(mfp.logger).to receive(:info).exactly(2).times
          expect(mfp.logger).to receive(:warn).with("Node extent in md.xml has attribute: unit")
          expect(mfp.logger).to_not receive(:error)
          mfp.scan
          expect(mfp.report).to include("1 WARNING and 0 ERRORS")
        end
      end
      context "element has unknown vocabulary term" do
        before { allow(File).to receive(:read).with(File.join(folder, "md.xml")).and_return(sample_mets_with_unknown_duketerm) }
        it "should report an error" do
          expect(mfp.logger).to receive(:info).exactly(2).times
          expect(mfp.logger).to_not receive(:warn)
          expect(mfp.logger).to receive(:error).with("Unknown element name unknown in md.xml")
          expect(mfp.logger).to receive(:error).with("Error adding value for unknown element to descriptive metadata: No such term: unknown")
          mfp.scan
          expect(mfp.report).to include("0 WARNINGS and 2 ERRORS")
        end
      end
      context "element with no namespace" do
        before { allow(File).to receive(:read).with(File.join(folder, "md.xml")).and_return(sample_mets_with_no_namespace_element) }
        it "should report an error" do
          expect(mfp.logger).to receive(:info).exactly(2).times
          expect(mfp.logger).to receive(:warn).with("Cannot validate element name abstract in md.xml")
          expect(mfp.logger).to receive(:error).with("Node abstract in md.xml does not have a namespace")
          mfp.scan
          expect(mfp.report).to include("1 WARNING and 1 ERROR")
        end
      end
      context "element with unknown namespace" do
        before { allow(File).to receive(:read).with(File.join(folder, "md.xml")).and_return(sample_mets_with_unknown_namespace) }
        it "should report an error" do
          expect(mfp.logger).to receive(:info).exactly(2).times
          expect(mfp.logger).to receive(:warn).with("Cannot validate element name extent in namespace special in md.xml")
          expect(mfp.logger).to receive(:error).with("Node extent in md.xml has unknown namespace prefix: special")
          mfp.scan
          expect(mfp.report).to include("1 WARNING and 1 ERROR")
        end
      end
      context "element with invalid namespace href" do
        before { allow(File).to receive(:read).with(File.join(folder, "md.xml")).and_return(sample_mets_with_invalid_namespace_href) }
        it "should report an error" do
          expect(mfp.logger).to receive(:info).exactly(2).times
          expect(mfp.logger).to_not receive(:warn)
          expect(mfp.logger).to receive(:error).with("Node dcmitype in md.xml with namespace prefix duke has invalid href http://library.duke.edu/metadata/duketerms")
          mfp.scan
          expect(mfp.report).to include("0 WARNINGS and 1 ERROR")
        end
      end      
    end
    
    describe "#report" do
      context "scan not run" do
        let(:mfp) { described_class.new({ folder: folder }) }
        it "should raise an exception" do
          expect { mfp.report }.to raise_error
        end
      end
      context "scan run" do
        let(:collection) { FactoryGirl.create(:collection) }
        let(:mfp) { described_class.new({ folder: folder, collection: collection }).tap { |p| p.scanner = scanner_hash } }
        let(:scanner_hash) { { "/tmp/a.xml" => { "sec_1" => { id: "id_1", pid: collection.pid, md: "testing" } } } }
        it "should provide the appropriate data" do
          report = mfp.report
          expect(report).to include("Metadata Folder Scan")
          expect(report).to include("Scanned #{folder}")
          expect(report).to include("Found #{scanner_hash.keys.count} file")
          expect(report).to include("Found 1 descriptive metadata section")
          expect(report).to include("Collection #{collection.title_display} has #{collection.items.count} item")
          expect(report).to include("Scan generated 0 WARNINGS and 0 ERRORS")
        end
      end
    end

    describe "#create_batch" do
      let(:user) { FactoryGirl.create(:user) }
      let(:object) { { id: "id_1", pid: "test:1" } }
      let(:mfp) { described_class.new({ folder: folder, user: user }).tap { |p| p.scanner = scanner_hash } }
      let(:scanner_hash) { { "/tmp/a.xml" => { "sec_1" => { id: object[:id], pid: object[:pid], md: "testing" } } } }
      it "should create the appropriate batch" do
        batch = mfp.create_batch
        expect(batch.status).to eq(DulHydra::Batch::Models::Batch::STATUS_READY)
        expect(batch.user).to eq(user)
        expect(batch.name).to eq("Metadata Folder")
        expect(batch.description).to eq(folder)
        expect(batch.batch_objects.size).to eq(1)
        batch_object = batch.batch_objects.first
        expect(batch_object).to be_a(DulHydra::Batch::Models::UpdateBatchObject)
        expect(batch_object.identifier).to eq(object[:id])
        expect(batch_object.pid).to eq(object[:pid])
        expect(batch_object.batch_object_datastreams.size).to eq(1)
        metadata_datastream = batch_object.batch_object_datastreams.first
        expect(metadata_datastream.name).to eq(Ddr::Datastreams::DESC_METADATA)
        expect(metadata_datastream.operation).to eq(DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE)
        expect(metadata_datastream.payload).to eq("testing")
        expect(metadata_datastream.payload_type).to eq(DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES)
      end
    end

  end

end