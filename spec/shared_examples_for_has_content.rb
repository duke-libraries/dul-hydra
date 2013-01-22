require 'spec_helper'
# require 'shared_examples_for_fixity_checkables'

shared_examples "an object that has content" do

  # it_behaves_like "a fixity checkable object"

  context "new" do
    let(:obj) { described_class.new }
    it "should have a content datastream" do
      obj.datastreams["content"].should be_kind_of(DulHydra::Datastreams::FileContentDatastream)
    end
  end

end
