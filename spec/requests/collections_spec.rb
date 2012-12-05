require 'spec_helper'

def logmein(user)
  visit new_user_session_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button 'Sign in'
end

def logmeout
  visit destroy_user_session_path
end

describe "Collections" do

  before do
    adminPolicyRightsMetadataFilePath = "spec/fixtures/apo.rightsMetadata.xml"
    adminPolicyRightsMetadataFile = File.open(adminPolicyRightsMetadataFilePath, "r")
    publicReadDefaultRightsFilePath = "spec/fixtures/apo.defaultRights_publicread.xml"
    publicReadDefaultRightsFile = File.open(publicReadDefaultRightsFilePath, "r")
    restrictedReadDefaultRightsFilePath = "spec/fixtures/apo.defaultRights_restrictedread.xml"
    restrictedReadDefaultRightsFile = File.open(restrictedReadDefaultRightsFilePath, "r")
    @publicReadAdminPolicy = AdminPolicy.new
    @publicReadAdminPolicy.defaultRights.content = publicReadDefaultRightsFile
    @publicReadAdminPolicy.rightsMetadata.content = adminPolicyRightsMetadataFile
    @publicReadAdminPolicy.save!
    @restrictedReadAdminPolicy = AdminPolicy.new
    @restrictedReadAdminPolicy.defaultRights.content = restrictedReadDefaultRightsFile
    @restrictedReadAdminPolicy.rightsMetadata.content = adminPolicyRightsMetadataFile
    @restrictedReadAdminPolicy.save!
    adminPolicyRightsMetadataFile.close
    publicReadDefaultRightsFile.close
    restrictedReadDefaultRightsFile.close
    @registeredUser = User.create!(email:'registereduser@nowhere.org', password:'registeredUserPassword')
    @repositoryReader = User.create!(email:'repositoryreader@nowhere.org', password:'repositoryReaderPassword')
    @forbiddenText = "The action you wanted to perform was forbidden."
  end
  
  after do
    @repositoryReader.delete
    @registeredUser.delete
    @restrictedReadAdminPolicy.delete
    @publicReadAdminPolicy.delete
  end

  describe "List" do
    before do
      title = "New Collection"
      @c1 = Collection.create(:title => title)
      @c2 = Collection.create
    end
    after do
      @c1.delete
      @c2.delete
    end
    it "should display the title if present, otherwise the pid" do
      visit collections_path
      page.should have_content @c1.title.first
      page.should have_content @c2.pid
    end
    it "should include a show link for each collection" do
      visit collections_path
      page.should have_link @c1.title.first, :href => collection_path(@c1)
      page.should have_link @c2.pid, :href => collection_path(@c2)
    end
    it "should contain a link to create a new collection" do
      visit collections_path
      page.should have_link "Create New Collection", :href => new_collection_path
    end
  end # List

  describe "Add" do
    before do
      @title = "Test Collection"
      @identifier = "collectionIdentifier"
      @adminPolicyPid = @publicReadAdminPolicy.pid
    end
    after do
      Collection.find_each { |c| c.delete }
    end
    context "user is not logged in" do
      it "should display a Forbidden (403) response" do
        visit new_collection_path
        page.should have_content @forbiddenText
      end
    end
    context "user is logged in" do
      before do
        logmein @registeredUser        
      end
      after do
        logmeout
      end
      it "should display the new collection page" do
        visit new_collection_path
        page.should have_content "Create a new Collection"
      end
      it "should create a collection with the provided metadata" do
        visit new_collection_path
        fill_in "Title", :with => @title
        fill_in "Identifier", :with => @identifier
        fill_in "Access Policy PID", :with => @adminPolicyPid
        click_button "Create Collection"
        page.should have_content "Added Collection"
        page.should have_content @title
        page.should have_content @identifier
        page.should have_content @adminPolicyPid
      end
    end
  end # Add

  describe "Show" do
    before do
      @collection = Collection.new
      @collection.title = "Collection Title"
      @collection.identifier = "collectionIdentifier"
      @collection.save!
      @member = Item.new
      @member.save!
      @collection.items << @member
    end
    after do
      @member.delete
      @collection.delete
    end
    shared_examples_for "a user-accessible collection" do
      it "should display the collection object title, identifier and pid" do
        visit collection_path(@collection)
        page.should have_content @collection.title.first
        page.should have_content @collection.identifier.first
        page.should have_content @collection.pid
      end
      it "should contain a link back to the collection list" do
        visit collection_path(@collection)
        page.should have_link "Collection List", :href => collections_path
      end
      it "should list the collection members" do # issue 16
        visit collection_path(@collection)
        page.should have_content @member.pid
      end
    end
    shared_examples_for "a user-forbidden collection" do
      before do
        @collection.clear_permissions!
      end
      it "should display a Forbidden (403) response" do
        visit collection_path(@collection)
        page.should have_content @forbiddenText
      end      
    end
    context "publicly readable collection" do
      # collection is readable by default
      # before do
      #   @collection.admin_policy = @publicReadAdminPolicy
      #   @collection.save!
      # end
      context "user is not logged in" do
        it_behaves_like "a user-accessible collection"
      end
      context "user is logged in" do
        before do
          logmein @registeredUser
        end
        after do
          logmeout
        end
        it_behaves_like "a user-accessible collection"
      end
    end
    context "restricted collection" do
      before do
        @collection.admin_policy = @restrictedReadAdminPolicy
        @collection.save!
      end
      context "user is not logged in" do
        it_behaves_like "a user-forbidden collection"
      end
      context "user is logged in but not have read access to collection" do
        before do
          logmein @registeredUser
        end
        after do
          logmeout
        end
        it_behaves_like "a user-forbidden collection"
      end
      context "user is logged and does have read access to collection" do
        before do
          logmein @repositoryReader
        end
        after do
          logmeout
        end
        it_behaves_like "a user-accessible collection"
      end
    end
  end

end
