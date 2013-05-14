require 'spec_helper'

describe "ManifestObject" do
  
  let(:manifest) { Manifest.new }
  let(:manifest_object) { ManifestObject.new({}, manifest) }
  
  context "batch" do
    it "should return the batch specified in the manifest" do
      expect(manifest_object.batch).to eq(manifest.batch)
    end
  end
    
end