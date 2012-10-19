require 'spec_helper'

describe "Collections" do
  describe "GET /collections" do
    before do
      @collection1 = Collection.create(:pid => "test:1")
      @collection2 = Collection.create(:pid => "test:2")
    end
    it "should display a list of all collections" do
      visit collections_path
      page.should have_content "test:1"
      page.should have_content "test:2"
    end
    after do
      @collection1.delete
      @collection2.delete
    end
  end
  it "should create a collection" do
    visit new_collection_path
    fill_in "Pid", :with => "test:1"
    click_button "Create"
    page.should have_content "Added Collection"
    page.should have_content "test:1"
  end
end
