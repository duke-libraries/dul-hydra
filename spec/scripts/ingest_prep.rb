require 'spec_helper'
require 'fileutils'
require './spec/scripts/batch_ingest_helpers'

RSpec.configure do |c|
  c.include BatchIngestHelpers
end

module DulHydra::Scripts
  
  describe BatchIngest do
    before do
      create_temp_dir
      define_paths_and_files
    end
    after do
      remove_temp_dir
    end
    describe "prepare for ingest" do
      before do
        FileUtils.mkdir_p "#{@manifest_base}"
        FileUtils.mkdir_p "#{@generic_master_base}"
        FileUtils.mkdir_p "#{@generic_marcxml_base}"
        FileUtils.mkdir_p "#{@generic_qdc_base}"
        FileUtils.cp "#{@fixture_manifest_filepath}", "#{@manifest_base}"
        FileUtils.cp "#{@fixture_generic_marcxml_filepath}", "#{@generic_marcxml_base}"
        @manifest_file = "#{@manifest_base}#{@manifest_filename}"
        update_manifest(@manifest_file, {"basepath" => "#{@generic_base}"})
      end
      it "should create an appropriate master file" do
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          master_file_contents = File.open("#{@generic_master_base}#{@master_filename}") {|io| io.read}
          expected_master_file_contents = File.open("#{@fixture_generic_master_filepath}") {|io| io.read}
          master_file_contents.should == expected_master_file_contents
      end
      it "should create appropriate qualified Dublin Core files" do
        DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
        for qdc_filename in qdc_filenames(@manifest_file)
          qdc_file_contents = File.open("#{@generic_qdc_base}#{@qdc_filename}") {|io| io.read}
          expected_qdc_file_contents = File.open("#{@fixture_generic_qdc_filepath}#{@qdc_filename}") {|io| io.read}
          qdc_file_contents.should == expected_qdc_file_contents
        end
      end
    end
  end
  
end
