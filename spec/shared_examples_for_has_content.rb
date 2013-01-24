require 'spec_helper'

shared_examples "an object that has content" do

  context "new" do
    let(:obj) { described_class.new }
    it "should have a content datastream" do
      obj.datastreams["content"].should be_kind_of(DulHydra::Datastreams::FileContentDatastream)
    end
  end

  context "#validate_content_checksum" do

  end

  context "#validate_content_checksum!" do

  end

end
