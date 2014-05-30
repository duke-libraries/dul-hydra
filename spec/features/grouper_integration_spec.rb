require 'spec_helper'
require 'dul_hydra'

describe "Grouper integration" do
  let(:user) { FactoryGirl.create(:user) }
  let(:object) { FactoryGirl.create(:collection) }
  before do
    object.title = "Grouper Works!"
    object.read_groups = ["duke:library:repository:ddr:foo:bar"]
    object.save!
    Warden.on_next_request do |proxy|
      proxy.env[DulHydra.remote_groups_env_key] = "urn:mace:duke.edu:groups:library:repository:ddr:foo:bar"
      proxy.set_user user
    end
  end
  it "should honor Grouper group access control" do
    visit url_for(object)
    page.should have_content("Grouper Works!")
  end
  
end
