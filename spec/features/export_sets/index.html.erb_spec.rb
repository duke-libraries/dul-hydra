require 'spec_helper'

describe "export_sets/index.html.erb" do
  context "user has no bookmarks" do
    it "should not have 'new export set' link"
  end
  context "user has bookmarks" do
    it "should have 'new export set' link"
  end
  context "user has an existing export set" do
    it "should link to the export set"
  end
  context "user has no export sets" do
    it "should display a 'no export sets' flash notice"
  end
end
