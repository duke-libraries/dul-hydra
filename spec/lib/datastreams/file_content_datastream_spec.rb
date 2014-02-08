require "spec_helper"

describe DulHydra::Datastreams::FileContentDatastream do
  before do
    class Foo < ActiveFedora::Base
      has_file_datastream "content", type: DulHydra::Datastreams::FileContentDatastream
    end
  end
  after do
    Object.send(:remove_const, :Foo)
  end
  let(:obj) { Foo.new }
  subject { obj.content }
  context "image content" do
    before { subject.stub(:mimeType).and_return("image/tiff") }
    it { should be_image }
  end
  context "not image content" do
    before { subject.stub(:mimeType).and_return("text/xml") }
    it { should_not be_image }
  end
end
