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

describe "Items" do

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
    @restrictedReadAdminPolicy.rightsMetadata.content = adminPolicyRightsMetadataFilePath
    @restrictedReadAdminPolicy.save!
    adminPolicyRightsMetadataFile.close
    publicReadDefaultRightsFile.close
    restrictedReadDefaultRightsFile.close
    @registeredUser = User.create!(email:'registereduser@nowhere.org', password:'registeredUserPassword')
    @repositoryReader = User.create!(email:'repositoryreader@nowhere.org', password:'repositoryReaderPassword')
    @repositoryEditor = User.create!(email:'repositoryeditor@nowhere.org', password:'repositoryEditorPassword')
    @forbiddenText = "The action you wanted to perform was forbidden."
  end
  
  after do
    @repositoryEditor.delete
    @repositoryReader.delete
    @registeredUser.delete
    @restrictedReadAdminPolicy.delete
    @publicReadAdminPolicy.delete
  end

  describe "list" do
    before do
      @item1 = Item.create
      @item2 = Item.create
      @item3 = Item.create(:title => "New Item 3")
      @item4 = Item.create(:title => "New Item 4")
    end
    after do
      @item1.delete
      @item2.delete
      @item3.delete
      @item4.delete
    end
    it "should display PIDs for items without titles" do
      visit items_path
      page.should have_content(@item1.pid)
      page.should have_content(@item2.pid)
    end
    it "should display titles for items with titles" do
      visit items_path
      page.should have_content(@item3.title.first)
      page.should have_content(@item4.title.first)
    end
  end # list

  describe "add" do
    before do
      @title = "Test Item"
      @identifier = "itemIdentifier"
      @adminPolicyPid = @publicReadAdminPolicy.pid
    end
    after do
      Item.find_each { |i| i.delete }
    end
    context "user is not logged in" do
      it "should display a Forbidden (403) response" do
        visit new_item_path
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
      it "should display the new item page" do
        visit new_item_path
        page.should have_content "Create a new Item"
      end
      it "should create an item with the provided metadata" do
        visit new_item_path
        fill_in "Title", :with => @title
        fill_in "Identifier", :with => @identifier
        fill_in "Access Policy PID", :with => @adminPolicyPid
        click_button "Create Item"
        page.should have_content "Added Item"
        page.should have_content @title
        page.should have_content @identifier
        page.should have_content @adminPolicyPid
      end
    end
  end # add
  
  describe "show" do
    before do
      @item = Item.new
      @item.save!
      @component = Component.create
      @item.parts << @component
      @item.save!
      @collection = Collection.create
    end
    after do
      @component.delete
      @collection.delete
      @item.delete
    end
    shared_examples_for "a user-accessible item" do
      it "should display the item pid" do
        visit item_path(@item)
        page.should have_content(@item.pid)
      end
      context "has parts" do
        it "should display the pids of the parts" do
          visit item_path(@item)
          page.should have_content(@component.pid)
        end        
      end
    end
    shared_examples_for "a user-forbidden item" do
      it "should display a Forbidden (403) response" do
        visit item_path(@item)
        page.should have_content @forbiddenText
      end
    end
    context "publicly readable item" do
      before do
        @item.admin_policy = @publicReadAdminPolicy
        @item.save!
        @collection.admin_policy = @publicReadAdminPolicy
        @collection.save!
      end
      context "user is not logged in" do
        it_behaves_like "a user-accessible item"
      end
      context "user is logged in" do
        before do
          logmein @registeredUser
        end
        after do
          logmeout
        end
        it_behaves_like "a user-accessible item"
      end
    end
    context "restricted item" do
      before do
        @item.admin_policy = @restrictedReadAdminPolicy
        @item.save!
      end
      context "user is not logged in" do
        it_behaves_like "a user-forbidden item"
      end
      context "user is logged in but not have read access to item" do
        before do
          logmein @registeredUser
        end
        after do
          logmeout
        end
        it_behaves_like "a user-forbidden item"
      end
      context "user is logged and does have read access to item" do
        before do
          logmein @repositoryReader
        end
        after do
          logmeout
        end
        it_behaves_like "a user-accessible item"
      end
    end
  end # show

  describe "update" do
    before do
      @item = Item.new
      @item.admin_policy = @publicReadAdminPolicy
      @item.save!
      @collection = Collection.create
    end
    after do
      @collection.delete
      @item.delete
    end
    shared_examples_for "a user-editable item" do
      context "not a member of a collection" do
        it "should be able to become a member of a collection" do
          visit item_path(@item)
          fill_in :collection, :with => @collection.pid
          click_button "Add Item to Collection"
          item_in_collection = Item.find(@item.pid)
          item_in_collection.collection.should eq(@collection)
          collection = Collection.find(@collection.pid)
          collection.items.should include(item_in_collection)
        end        
      end
    end
    shared_examples_for "an edit-forbidden item" do
      it "should display a Forbidden (403) response" do
        visit edit_item_path(@item)
        page.should have_content @forbiddenText
      end
    end
    context "user is logged in and has edit access to item" do
      before do
        logmein @repositoryEditor
      end
      after do
        logmeout
      end
      it_behaves_like "a user-editable item"
    end
  end # update

end
