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
      FileUtils.mkdir_p "#{@manifest_base}"
    end
    after do
      remove_temp_dir
    end
    describe "prepare for ingest" do
      before do
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
    describe "ingest" do
      before do
        FileUtils.mkdir_p "#{@generic_master_base}"
        FileUtils.cp "#{@fixture_generic_master_filepath}", "#{@generic_master_base}"
        FileUtils.cp "#{@fixture_manifest_filepath}", "#{@manifest_base}"
        @manifest_file = "#{@manifest_base}#{@manifest_filename}"
        update_manifest(@manifest_file, {"basepath" => "#{@generic_base}"})
        @adminPolicy = AdminPolicy.new(pid: 'duke-apo:adminPolicy', label: 'Public Read')
        @adminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS,
                                            DulHydra::Permissions::READER_GROUP_ACCESS,
                                            DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                            DulHydra::Permissions::ADMIN_GROUP_ACCESS]
        @adminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
        @adminPolicy.save!
        @ingested_identifiers = [ [ "identifier_1" ], [ "identifier_2", "identifier_3" ], [ "identifier_4" ] ]
      end
      after do
        Item.find_each { |i| i.delete }
        @adminPolicy.delete
      end
      it "should create an appropriate object in the repository" do
        DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        objects = Item.all
        objects.should have(3).things
        objects.each do |object|
          object.admin_policy.should == @adminPolicy
          @ingested_identifiers.should include(object.identifier)
          case object.identifier
          when [ "identifier_1" ]
            object.label.should == "Manifest Label"
            object.title.should == [ "Manifest Title" ]
          when [ "identifier_2", "identifier_3" ]
            object.label.should == "Second Object Label"
            object.title.should == [ "Manifest Title" ]
          when [ "identifier_4" ]
            object.label.should == "Manifest Label"
            object.title.should == [ "Title of Third Object" ]
          end
        end
      end
      it "should update the master file with the ingested PIDs" do
        DulHydra::Scripts::BatchIngest.ingest(@manifest_file)
        master = File.open("#{@generic_master_base}#{@master_filename}") { |f| Nokogiri::XML(f) }
        master.xpath("/objects/object").each do |object|
          identifier = object.xpath("identifier").first.content
          object.xpath("pid").should_not be_empty
          pid = object.xpath("pid").first.content
          repo_object = Item.find(pid)
          repo_object.identifier.should include(identifier)
        end
      end
    end
  end
  
end
