require 'spec_helper'

RSpec.describe ValidateMETSFile, type: :service, batch: true, mets_file: true do

  let(:collection) { Collection.new }
  let(:mets_filepath) { '/tmp/mets.xml' }
  let(:mets_file) { METSFile.new(mets_filepath, collection) }
  let(:validation_service) { described_class.new(mets_file) }

  before { allow(Ddr::Utils).to receive(:pid_for_identifier).and_call_original }

  context "valid file" do
    before do
      allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml }
      allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
      allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030010', model: 'Component') { 'test:7' }
      allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030020', model: 'Component') { 'test:8' }
    end
    it "should return no errors or warnings" do
      results = validation_service.call
      expect(results.errors).to be_empty
      expect(results.warnings).to be_empty
    end
  end

  context "invalid file" do
    context "no matching repository object" do
      before do
        allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml }
        allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { nil }
        allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030010') { 'test:7' }
      end
      it "should return a warning" do
        results = validation_service.call
        expect(results.warnings).to include("#{mets_file.filepath}: Repository object not found for local id #{mets_file.local_id}")
      end
    end
    context "invalid descriptive metadata" do
      context "element has attribute" do
        before do
          allow(File).to receive(:read).with(mets_filepath) { sample_mets_with_element_attribute }
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
        end
        it "should return a warning" do
          results = validation_service.call
          expect(results.warnings).to include("#{mets_file.filepath}: Node extent has attribute: unit")
        end
      end
      context "element has unknown vocabulary term" do
        before do
          allow(File).to receive(:read).with(mets_filepath) { sample_mets_with_unknown_duketerm }
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
        end
        it "should report an error" do
          results = validation_service.call
          expect(results.errors).to include("#{mets_file.filepath}: Unknown element name unknown")
        end
      end
      context "element with no namespace" do
        before do
          allow(File).to receive(:read).with(mets_filepath) { sample_mets_with_no_namespace_element }
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
        end
        it "should report a warning and an error" do
          results = validation_service.call
          expect(results.warnings).to include("#{mets_file.filepath}: Cannot validate element name abstract")
          expect(results.errors).to include("#{mets_file.filepath}: Node abstract does not have a namespace")
        end
      end
      context "element with unknown namespace" do
        before do
          allow(File).to receive(:read).with(mets_filepath) { sample_mets_with_unknown_namespace }
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
        end
        it "should report a warning and an error" do
          results = validation_service.call
          expect(results.warnings).to include("#{mets_file.filepath}: Cannot validate element name extent in namespace special")
          expect(results.errors).to include("#{mets_file.filepath}: Node extent has unknown namespace prefix: special")
        end
      end
      context "element with invalid namespace href" do
        before do
          allow(File).to receive(:read).with(mets_filepath) { sample_mets_with_invalid_namespace_href }
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
        end
        it "should report an error" do
          results = validation_service.call
          expect(results.errors).to include("#{mets_file.filepath}: Node dcmitype with namespace prefix duke has invalid href http://library.duke.edu/metadata/duketerms")
        end
      end
    end
    context "missing root type attribute" do
      before do
        allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml_with_missing_type_attr }
        allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
      end
      it "should report a warning" do
        results = validation_service.call
        expect(results.warnings).to include("#{mets_file.filepath}: Missing TYPE attribute on root node")
      end
    end
    context "invalid admin metadata" do
      context "source" do
        context "EAD ID without ArchivesSpace ID" do
          before do
            allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml_with_ead_id_no_aspace_id }
          end
          it "should report a warning" do
            results = validation_service.call
            expect(results.warnings).to include("#{mets_file.filepath}: EAD ID but no ArchivesSpace ID")
          end
        end
        context "ArchivesSpace ID without EAD ID" do
          before do
            allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml_with_aspace_id_no_ead_id }
          end
          it "should report a warning" do
            results = validation_service.call
            expect(results.warnings).to include("#{mets_file.filepath}: ArchivesSpace ID but no EAD ID")
          end
        end
      end
    end
    context "invalid struct metadata" do
      context "missing ID attribute" do
        before do
          allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml_with_missing_div_id_attr }
          # allow(Ddr::Utils).to receive(:pid_for_identifier).and_call_original
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
          allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030010', model: 'Component') { 'test:7' }
        end
        it "should report an error" do
          results = validation_service.call
          expect(results.errors).to include("#{mets_file.filepath}: Div does not have ID attribute")
        end
      end
      context "no repository object matching ID attribute" do
        context "missing ID attribute" do
          before do
            allow(File).to receive(:read).with(mets_filepath) { sample_mets_xml }
            allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi01003', collection: collection) { 'test:5' }
            allow(Ddr::Utils).to receive(:pid_for_identifier).with('efghi010030010', model: 'Component') { nil }
          end
          it "should report an error" do
            results = validation_service.call
            expect(results.errors).to include("#{mets_file.filepath}: Unable to locate repository object for div ID efghi010030010")
          end
        end
      end
    end
  end

end
