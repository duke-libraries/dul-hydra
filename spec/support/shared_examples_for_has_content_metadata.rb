require 'spec_helper'
require 'tempfile'

shared_examples "an object that has content metadata" do
  let!(:object) { described_class.create! }
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'fixtures', 'contentMetadata.xml') }
  before do
    object.contentMetadata.content_file = File.new(file_path, "r")
    object.save!
  end
  after { object.delete }
  context "contentMetadata datastream" do
    let(:expected_result) do
      [
        {
          "div" => [
            {
              "type" => "image",
              "label" => "Images",
              "div" => [
                {
                  "pids" => [
                    {
                      "pid" => "test:1",
                      "use" => "Master Image"
                    }
                  ]
                },
                {
                  "pids" => [
                    {
                      "pid" => "test:2",
                      "use" => "Master Image"
                    }
                  ]
                },
                {
                  "pids" => [
                    {
                      "pid" => "test:3",
                      "use" => "Master Image"
                    }
                  ]
                }
              ]
            },
            {
              "type" => "pdf",
              "label" => "PDF",
              "pids" => [
                {
                  "pid" => "test:4",
                  "use" => "Composite PDF"
                }
              ]
            }
            
          ]
        }
      ]
    end
    context "#parse" do
      it "should produce the appropriate result" do
        result = object.contentMetadata.parse
        result.should eq(expected_result)
      end
    end
    context "#to_solr" do
      let(:solr_result) { ActiveFedora::SolrService.query("id:#{object.pid.gsub(':', '\\:')}").first }
      it "should add the parsed contentMetadata to the index" do
        JSON.parse(solr_result[ActiveFedora::SolrService.solr_name(:content_metadata_parsed, :symbol)].first).should eq(expected_result)
      end
    end
  end
end
