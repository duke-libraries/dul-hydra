require 'spec_helper'
require 'helpers/user_helper'

describe "export_sets/index.html.erb" do
  let!(:user) { FactoryGirl.create(:user) }
  before do
    login user
    visit export_sets_path
  end
  after { user.delete }
  context "user has no bookmarks" do
    it "should not have a 'new export set' link" do
      page.should_not have_link("New Export Set")
    end
  end
  context "user has bookmarks" do
    pending
  end
  context "user has an existing export set" do
    pending
  end
  context "user has no export sets" do
    it "should display a 'no export sets' flash notice" do
      page.should have_content("no export sets")
    end
  end
end
