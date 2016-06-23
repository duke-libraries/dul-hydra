require 'spec_helper'

RSpec.describe VersionCreationJob, jobs: true, versioning: true do

  it "should use the :versioning queue" do
    expect(described_class.queue).to eq(:versioning)
  end

  describe ".perform" do
    let!(:obj) { double(create_version: nil) }
    before do
      allow(ActiveFedora::Base).to receive(:find).with("test-1") { obj }
    end
    it "should call `create_version` on the object" do
      expect(obj).to receive(:create_version)
      described_class.perform("test-1")
    end
  end

end
