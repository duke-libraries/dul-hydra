require 'spec_helper'
require 'fileutils'
require "#{Rails.root}/spec/scripts/batch_ingest_spec_helper"

RSpec.configure do |c|
  c.include BatchIngestSpecHelper
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
        FileUtils.mkdir_p "#{@generic_contentdm_base}"
        FileUtils.mkdir_p "#{@generic_master_base}"
        FileUtils.mkdir_p "#{@generic_marcxml_base}"
        FileUtils.mkdir_p "#{@generic_qdc_base}"
        FileUtils.cp "#{@fixture_manifest_filepath}", "#{@manifest_base}"
        FileUtils.cp "#{@fixture_generic_contentdm_filepath}", "#{@generic_contentdm_base}"
        FileUtils.cp "#{@fixture_generic_marcxml_filepath}", "#{@generic_marcxml_base}"
        @manifest_file = "#{@manifest_base}#{@manifest_filename}"
        update_manifest(@manifest_file, {"basepath" => "#{@generic_base}"})
      end
      it "should create an appropriate master file" do
          DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
          result = File.open("#{@generic_master_base}#{@master_filename}") { |f| Nokogiri::XML(f) }
          expected = File.open("#{@fixture_generic_master_filepath}") { |f| Nokogiri::XML(f) }
          result.should be_equivalent_to(expected)
      end
      it "should create appropriate qualified Dublin Core files" do
        DulHydra::Scripts::BatchIngest.prep_for_ingest(@manifest_file)
        for qdc_filename in qdc_filenames(@manifest_file)
          result = File.open("#{@generic_qdc_base}#{qdc_filename}") { |f| Nokogiri::XML(f) }
          expected = File.open("#{@fixture_generic_qdc_base}#{qdc_filename}") { |f| Nokogiri::XML(f) }
          result.should be_equivalent_to(expected)
        end
      end
    end
  end
  
end
