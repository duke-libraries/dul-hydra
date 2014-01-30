require 'spec_helper'

shared_examples "an object that has a thumbnail" do
  let(:object) do
    described_class.new.tap do |obj|
      obj.title = 'I have a thumbnail'
      obj.save(validate: false)
    end
  end
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
