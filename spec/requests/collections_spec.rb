require 'spec_helper'

describe "Collections" do
  describe "GET /collections" do
    before do
      @pid1 = "collection:1"
      @pid2 = "collection:2"
      @collection1 = Collection.create(:pid => @pid1)
      @collection2 = Collection.create(:pid => @pid2)
    end
    it "should display a list of all collections" do
      visit collections_path
      page.should have_content @pid1
      page.should have_content @pid2
    end
    after do
      @collection1.delete
      @collection2.delete
    end
  end
  describe "POST /collection" do
    before do
      @pid = "collection:1"
    end
    after do
      Collection.find(@pid).delete
    end
    it "should create a collection" do
      visit new_collection_path
      fill_in "Pid", :with => @pid
      click_button "Create Collection"
      page.should have_content "Added Collection"
      page.should have_content @pid
    end
  end
end
