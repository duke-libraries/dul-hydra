require 'spec_helper'

describe "Grouper integration", :type => :feature do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:collection) }
  before do
    object.title = [ "Grouper Works!" ]
    object.read_groups = ["duke:library:repository:ddr:foo:bar"]
    object.save!
    Warden.on_next_request do |proxy|
      proxy.env[Ddr::Auth.remote_groups_env_key] = "urn:mace:duke.edu:groups:library:repository:ddr:foo:bar"
      proxy.set_user user
    end
  end
  it "should honor Grouper group access control" do
    visit url_for(object)
    expect(page).to have_content("Grouper Works!")
  end
  
end
