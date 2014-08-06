require 'spec_helper'

module DulHydra
  describe FileManagement do
    let(:object) { FileManageable.new }
    let(:file) { fixture_file_upload("library-devil.tiff", "image/tiff") }
    before(:all) do
      class FileManageable < ActiveFedora::Base
        include DulHydra::FileManagement
        has_file_datastream name: "e_content", control_group: "E"
        has_file_datastream name: "m_content", control_group: "M"
      end
    end
    describe "#add_file" do
      it "should run a virus scan on the file" do
        expect(DulHydra::Services::Antivirus).to receive(:scan).with(file)
        expect(object).to receive(:virus_scan).and_call_original
        object.add_file file, "m_content"
      end
      it "should call add_file_datastream by default" do
        expect(object).to receive(:add_file_datastream)
        object.add_file file, "random_ds_1"
      end
      it "should call add_file_datastream when dsid spec is managed" do
        expect(object).to receive(:add_file_datastream)
        object.add_file file, "m_content"
      end
      it "should call add_external_file when dsid spec is external" do
        expect(object).to receive(:add_external_file).with(file, "e_content", {mime_type: file.content_type, file_name: file.original_filename})
        object.add_file file, "e_content"
      end
      it "should call add_external_file when :external => true option passed" do
        expect(object).to receive(:add_external_file).with(file, "random_ds_2", {mime_type: file.content_type, file_name: file.original_filename})
        object.add_file file, "random_ds_2", external: true
      end
    end
    describe "#add_external_file" do
      it "should call add_external_datastream if no spec for dsid" do
        expect(object).to receive(:add_external_datastream).with("random_ds_3").and_call_original
        object.add_external_file(file, "random_ds_3")
      end
      it "should raise an error if datastream is not external" do
        expect { object.add_external_file(file, "m_content") }.to raise_error 
      end
      it "should raise an error if dsLocation has changed" do
        allow(object.e_content).to receive(:dsLocation_changed?) { true }
        expect { object.add_external_file(file, "e_content") }.to raise_error
      end
      it "should set the mimeType" do
        expect(object.e_content).to receive(:mimeType=).with("image/tiff")
        object.add_external_file(file, "e_content")
      end
      it "should set dsLocation to URI for original file path if :use_original => true option" do
        expect(object.e_content).to receive(:dsLocation=).with(URI.escape("file:#{file.path}"))
        object.add_external_file(file, "e_content", use_original: true)
      end
      it "should set dsLocation to URI for generated file path by default"
    end
    describe "#add_external_datastream" do
      it "should return a new external datastream" do
        ds = object.add_external_datastream("random_ds_27")
        expect(ds.controlGroup).to eq "E"
        expect(object.datastreams["random_ds_27"]).to eq ds
        expect(object.random_ds_27).to eq ds
      end
    end
    describe "#external_datastream_file_paths" do
      let(:file1) { fixture_file_upload("image1.tiff", "image/tiff") }
      let(:file2) { fixture_file_upload("image1.tiff", "image/tiff") }
      let(:file3) { fixture_file_upload("image1.tiff", "image/tiff") }
      before do
        object.add_file(file1, "e_content")
        object.save
        object.add_file(file2, "e_content")
        object.save
        object.add_file(file3, "e_content_2", external: true)
        object.save
      end      
      it "should return a list of file paths for all versions of all external datastreams for the object" do
        expect(object.external_datastream_file_paths.size).to eq 3
        object.external_datastream_file_paths.each do |path|
          expect(File.exists?(path)).to be true
        end
      end
    end
    describe "#generate_external_file_path" do
      
    end
  end
end
