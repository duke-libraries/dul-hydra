require 'spec_helper'

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :broken => true
end

describe "Collections" do

  @pid1 = "collection:1"
  @pid2 = "collection:2"

  describe "GET /collections" do

    before do
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

  end # GET (index/list)

  describe "POST /collections" do

    it "should create a collection", :broken => true do
      visit new_collection_path
      fill_in "Pid", :with => @pid1
      click_button "Create Collection"
      page.should have_content "Added Collection"
      page.should have_content @pid1
    end

    after do
      Collection.find(@pid1).delete
    end

  end # POST (create)

end
