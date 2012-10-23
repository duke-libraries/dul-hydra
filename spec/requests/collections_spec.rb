require 'spec_helper'

describe "Collections" do
  describe "List collections" do
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
  describe "Add collection" do
    before do
      @pid = "collection:1"
      @empty_string_pid = ""
      @default_pid_namespace = "changeme"
    end
    after do
      Collection.find_each { |c| c.delete }
    end
    it "should create a collection with provided PID" do
      visit new_collection_path
      fill_in "Pid", :with => @pid
      click_button "Create Collection"
      page.should have_content "Added Collection"
      page.should have_content @pid
    end
    it "should create a collection with system-assigned PID" do
      visit new_collection_path
      click_button "Create Collection"
      page.should have_content "Added Collection"
      page.should have_content @default_pid_namespace
    end
    it "should create a collection with system-asigned PID if given blank PID" do
      visit new_collection_path
      fill_in "Pid", :with => @empty_string_pid
      click_button "Create Collection"
      page.should have_content "Added Collection"
      page.should have_content @default_pid_namespace
    end
  end
end
