require 'spec_helper'
require 'tempfile'

describe DulHydra::Datastreams::FileContentDatastream do
  let(:obj) { FileContentObject.create }
  let(:pid_prefix) { obj.pid.sub(':', '_') }
  let(:ds) { obj.datastreams['content'] }
  before(:all) do
    class FileContentObject < ActiveFedora::Base
      has_file_datastream name: 'content', type: DulHydra::Datastreams::FileContentDatastream
    end
  end
  before(:each) do
    obj.content.content = fixture_file_upload("library-devil.tiff", "image/tiff")
    obj.save!
  end
  after(:each) { ActiveFedora::Base.destroy_all }
  after(:all) { Object.send(:remove_const, :FileContentObject) }
  it "should have a default file prefix, file extension, and file name" do
    expect(ds.default_file_prefix).to  eq("#{pid_prefix}_content")
    expect(ds.default_file_extension).to eq("tiff")
    expect(ds.default_file_name).to eq("#{pid_prefix}_content.tiff")
  end
  context "#write_content" do
    it "should write the content to a file" do
      Tempfile.new('content', :encoding => 'ascii-8bit') do |tmpfile|
        tmppath = tmpfile.path
        ds.write_content(tmpfile)
        ds.size.should == File.size(tmppath)
      end
    end
  end
end
