require 'spec_helper'

module DulHydra::Migration
  RSpec.describe StructMetadata do

    subject { described_class.new(item) }

    let(:item) { Item.new(id: item_id) }
    let(:item_id) { "uv/wx/yz/uvwxyz7890" }
    let(:structMetadata) { ActiveFedora::File.new }
    let(:ar_a) { ActiveFedora::Relation.new(Component) }
    let(:ar_b) { ActiveFedora::Relation.new(Component) }
    let(:old_struct_metadata) do
      <<-EOS
          <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
            <structMap TYPE="default">
              <div ID="dscsi010010010" LABEL="Recto" ORDER="1">
                <fptr CONTENTIDS="info:fedora/test:3"/>
              </div>
              <div ID="dscsi010010020" LABEL="Verso" ORDER="2">
                <fptr CONTENTIDS="info:fedora/test:5"/>
              </div>
              </structMap>
          </mets>
      EOS
    end
    let(:new_struct_metadata) do
      <<-EOS
          <mets xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink">
            <structMap TYPE="default">
              <div ID="dscsi010010010" LABEL="Recto" ORDER="1">
                <fptr CONTENTIDS="ab/cd/ef/abcdefghij"/>
              </div>
              <div ID="dscsi010010020" LABEL="Verso" ORDER="2">
                <fptr CONTENTIDS="12/34/56/1234567890"/>
              </div>
              </structMap>
          </mets>
      EOS
    end



    describe "#migrate" do

      before do
        allow(item).to receive(:structMetadata) { structMetadata }
        allow(structMetadata).to receive(:content) { old_struct_metadata }
      end

      describe "successful migration" do
        before do
          allow(item).to receive(:has_struct_metadata?) { true }
          allow(subject).to receive(:transmogrify) { new_struct_metadata }
          allow(item).to receive(:save) { true }
        end
        it "should not raise an exception" do
          expect { subject.migrate }.not_to raise_error
        end
      end

      describe "no structMetadata to migrate" do
        before do
          allow(item).to receive(:has_struct_metadata?) { false }
        end
        it "should raise an excpetion" do
          expect { subject.migrate }.to raise_error(FedoraMigrate::Errors::MigrationError,
                                                    "#{item_id}: No structMetadata to migrate")
        end
      end

      describe "structMetadata unchanged" do
        before do
          allow(item).to receive(:has_struct_metadata?) { true }
          allow(subject).to receive(:transmogrify) { old_struct_metadata }
        end
        it "should raise an exception" do
          expect { subject.migrate }.to raise_error(FedoraMigrate::Errors::MigrationError,
                                                    "#{item_id}: Migration did not change structMetadata")
        end
      end

      describe "saving item fails" do
        before do
          allow(item).to receive(:has_struct_metadata?) { true }
          allow(item).to receive(:save) { false }
          allow(subject).to receive(:transmogrify) { new_struct_metadata }
        end
        it "should raise an exception" do
          expect { subject.migrate }.to raise_error(FedoraMigrate::Errors::MigrationError,
                                                    "#{item_id}: Unable to save migrated structMetadata")
        end
      end

    end

    describe "#transmogrify" do

      before do
        allow(ActiveFedora::Base).to receive(:where).and_call_original
        allow(ActiveFedora::Base).to receive(:where).with(Ddr::Index::Fields::FCREPO3_PID => 'test:3') { ar_a }
        allow(ar_a).to receive(:first) { double(id: "ab/cd/ef/abcdefghij") }
      end

      describe "successful transmogrification" do
        before do
          allow(ActiveFedora::Base).to receive(:where).with(Ddr::Index::Fields::FCREPO3_PID => 'test:5') { ar_b }
          allow(ar_b).to receive(:first) { double(id: "12/34/56/1234567890") }
        end
        it "should replace the Fedora 3 URI's with Fedora 4 ID's" do
          expect(subject.transmogrify(old_struct_metadata)).to be_equivalent_to(new_struct_metadata)
        end
      end

      describe "Fedora 4 object not found for Fedora 3 PID" do
        it "should raise an exception" do
          expect { subject.transmogrify(old_struct_metadata) }.to raise_error(FedoraMigrate::Errors::MigrationError,
                                                                  "#{item_id}: Unable to find Fedora 4 ID for test:5")
        end
      end
    end

  end
end
