require 'spec_helper'

def logmein
  visit new_user_session_path
  @userA = User.create!(:email=>'user3@nowhere.org', :password=>'supersecretUserApassword')
  fill_in "Email", with: @userA.email
  fill_in "Password", with: "supersecretUserApassword"
  click_button 'Sign in'
end

describe "Collections" do

  after do
    Collection.find_each { |c| c.delete }
  end

  describe "List" do
    it "should include a show link for each collection" do
      title = "New Collection"
      c1 = Collection.create(:title => title)
      c2 = Collection.create
      visit collections_path
      page.should have_link c1.title.first, :href => collection_path(c1)
      page.should have_link c2.pid, :href => collection_path(c2)
    end
    it "should display the title if present, otherwise the pid" do
      title = "New Collection"
      c1 = Collection.create(:title => title)
      c2 = Collection.create
      visit collections_path
      page.should have_content c1.title.first
      page.should have_content c2.pid
    end
    it "should contain a link to create a new collection" do
      visit collections_path
      page.should have_link "Create New Collection", :href => new_collection_path
    end
  end # List

  describe "Show" do
    before do
      logmein
    end
    after do
      Item.find_each { |i| i.delete }
    end
    it "should display the collection object title, identifier and pid" do
      c = Collection.create(:title => "Collection", :identifier => "test010010010")
      visit collection_path(c)
      page.should have_content c.title.first
      page.should have_content c.identifier.first
      page.should have_content c.pid
    end
    it "should contain a link back to the collection list" do
      visit collection_path(Collection.create)
      page.should have_link "Collection List", :href => collections_path
    end
    it "should list the collection members" do # issue 16
      c = Collection.create
      member = Item.create
      c.items << member
      visit collection_path(c)
      page.should have_content member.pid
    end
  end
  describe "Add" do
    before do
      logmein
    end
#    it "should create a collection with provided PID" do
#      visit new_collection_path
#      fill_in "Pid", :with => @pid
#      click_button "Create Collection"
#      page.should have_content "Added Collection"
#      page.should have_content @pid
#    end
#    it "should create a collection with system-assigned PID" do
#      visit new_collection_path
#      click_button "Create Collection"
#      page.should have_content "Added Collection"
#      page.should have_content @default_pid_namespace
#    end
#    it "should create a collection with system-asigned PID if given blank PID" do
#      visit new_collection_path
#      fill_in "Pid", :with => @empty_string_pid
#      click_button "Create Collection"
#      page.should have_content "Added Collection"
#      page.should have_content @default_pid_namespace
#    end
    it "should create a collection with the provided metadata" do
      title = "Test Collection"
      identifier = "collectionIdentifier"
      visit new_collection_path
      fill_in "Title", :with => title
      fill_in "Identifier", :with => identifier
      click_button "Create Collection"
      page.should have_content "Added Collection"
      page.should have_content title
      page.should have_content identifier
    end
  end # Add

end
