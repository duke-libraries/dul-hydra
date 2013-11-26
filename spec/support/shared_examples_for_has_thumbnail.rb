require 'spec_helper'

shared_examples "an object that has a thumbnail" do
  let!(:object) { described_class.create!(title: 'I have a thumbnail') }
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
