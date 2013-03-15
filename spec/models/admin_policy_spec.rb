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
  context ".load_policies" do
    before do
      @pid = 'duke-apo:TestPolicy'
      @file_path = File.join(Rails.root, 'spec', 'fixtures', 'admin_policies.yml')
    end
    context "policy exists" do
      before do
        @apo = AdminPolicy.create(:pid => @pid, :title => 'Not loaded from file')
        AdminPolicy.load_policies(@file_path)
      end
      after { @apo.delete }
      it "should not overwrite the existing policy" do
        AdminPolicy.find(@pid).title.should == 'Not loaded from file'
      end
    end
    context "policy does not exist" do
      after { AdminPolicy.find(@pid).delete }
      it "should create the policy" do
        lambda { AdminPolicy.find(@pid) }.should raise_error(ActiveFedora::ObjectNotFoundError)
        AdminPolicy.load_policies(@file_path)
        lambda { AdminPolicy.find(@pid) }.should_not raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
end
