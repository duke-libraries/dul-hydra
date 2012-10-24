require 'spec_helper'

describe "Collections" do
  describe "List collections" do
    before do
      @collection1 = Collection.new
      @collection1.title = "Collection 1 Title"
      @collection1.save!
      @collection2 = Collection.create
    end
    after do
      @collection1.delete
      @collection2.delete
    end
    it "should include a show link for each collection" do
      visit collections_path
      page.should have_link @collection1.title.first, :href=>collection_path(@collection1)
      page.should have_link @collection2.pid, :href=>collection_path(@collection2)
    end
    it "should display the title of the collection if there is one" do
      visit collections_path
      page.should have_content @collection1.title.first
      page.should have_content @collection2.pid
    end
  end
  describe "Show collection" do
    before do
      @collection = Collection.new
      @collection.title = "Collection Title"
      @collection.identifier = "collectionIdentifier"
      @collection.save!
    end
    after do
      Collection.find_each { |c| c.delete }
    end
    it "should display the collection object" do
      visit collection_path(@collection)
      page.should have_content "Collection Title"
      page.should have_content "collectionIdentifier"
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
