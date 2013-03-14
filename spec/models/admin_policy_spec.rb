require 'spec_helper'

describe AdminPolicy do
  context "terms delegated to defaultRights" do
    let(:apo) { AdminPolicy.new }
    before do
      apo.default_license_title = "License Title"
      apo.default_license_description = "License Description"
      apo.default_license_url = "http://library.duke.edu"
    end
    it "should set the terms correctly" do
      apo.defaultRights.license.title.first.should == "License Title"
      apo.defaultRights.license.description.first.should == "License Description"
      apo.defaultRights.license.url.first.should == "http://library.duke.edu"
    end
  end
end
