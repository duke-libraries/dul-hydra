require 'spec_helper'

shared_examples "an object that has a thumbnail" do
  let!(:object) { described_class.create! }
  after { object.delete }
  context "before thumbnail creation" do
    it "should not have a thumbnail" do
      object.has_thumbnail?.should be_false
    end
  end
  context "after thumbnail creation" do
    it "should have a thumbnail"
  end
end
