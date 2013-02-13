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

describe "Components" do

  before(:all) do
    @filepath = "spec/fixtures/library-devil.tiff"
  end
  
  before do
    @publicReadAdminPolicy = AdminPolicy.new(label: 'Public Read')
    @publicReadAdminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_READ_ACCESS,
                                                  DulHydra::Permissions::READER_GROUP_ACCESS,
                                                  DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                                  DulHydra::Permissions::ADMIN_GROUP_ACCESS]
    @publicReadAdminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
    @publicReadAdminPolicy.save!

    @restrictedReadAdminPolicy = AdminPolicy.new(label: 'Restricted Read')
    @restrictedReadAdminPolicy.default_permissions = [DulHydra::Permissions::PUBLIC_DISCOVER_ACCESS,
                                                      DulHydra::Permissions::READER_GROUP_ACCESS,
                                                      DulHydra::Permissions::EDITOR_GROUP_ACCESS,
                                                      DulHydra::Permissions::ADMIN_GROUP_ACCESS]
    @restrictedReadAdminPolicy.permissions = AdminPolicy::APO_PERMISSIONS
    @restrictedReadAdminPolicy.save!

    @registeredUser = User.create!(email: 'registereduser@nowhere.org', password: 'registeredUserPassword')
    @repositoryReader = User.create!(email: 'repositoryreader@nowhere.org', password: 'repositoryReaderPassword')
    @repositoryEditor = User.create!(email: 'repositoryeditor@nowhere.org', password: 'repositoryReaderPassword')

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
      @component1 = Component.create
      @component2 = Component.create
    end
    after do
      @component1.delete
      @component2.delete
    end
    it "should display a list of all components" do
      visit components_path
      page.should have_content @component1.pid
      page.should have_content @component2.pid
    end
  end # list components

  describe "create" do
    before do
      @adminPolicyPid = @publicReadAdminPolicy.pid
    end
    after do
      Component.find_each { |c| c.delete }
    end
    context "user is not logged in" do
      it "should display a Forbidden (403) response" do
        visit new_component_path
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
      it "should display the new component page" do
        visit new_component_path
        page.should have_content "New Component"
      end
      it "should be able to create a component having a content file" do
        visit new_component_path
        attach_file "Content File", "spec/fixtures/library-devil.tiff"
        select @adminPolicyPid, :from => :policypid
        click_button "Create Component"
        page.should have_content @adminPolicyPid
        page.should have_content "Component created"
        page.should have_content "image/tiff"
      end
    end
  end # create

  # describe "show" do
  #   before do
  #     @component = Component.create
  #   end
  #   after do
  #     Component.find_each { |c| c.delete }
  #     Item.find_each { |i| i.delete }
  #   end
  #   shared_examples_for "a user-accessible component" do
  #     context "component has content" do
  #       before do
  #         @component.content.content_file = File.new(@filepath)
  #         @component.save
  #       end
  #       it "should display information about the content" do
  #         visit component_path(@component)
  #         page.should have_content @component.content.mimeType
  #         page.should have_content @component.content.size
  #       end              
  #     end
  #   end
  #   shared_examples_for "a user-forbidden component" do
  #     it "should display a Forbidden (403) response" do
  #       visit component_path(@component)
  #       page.should have_content @forbiddenText
  #     end      
  #   end
  #   context "publicly readable component" do
  #     before do
  #       @component.admin_policy = @publicReadAdminPolicy
  #       @component.save!
  #     end
  #     context "user is not logged in" do
  #       it_behaves_like "a user-accessible component"
  #     end
  #     context "user is logged in" do
  #       before do
  #         logmein @registeredUser
  #       end
  #       after do
  #         logmeout
  #       end
  #       it_behaves_like "a user-accessible component"
  #     end
  #   end
  #   context "restricted collection" do
  #     before do
  #       @component.admin_policy = @restrictedReadAdminPolicy
  #       @component.save!
  #     end
  #     context "user is not logged in" do
  #       it_behaves_like "a user-forbidden component"
  #     end
  #     context "user is logged in but does not have read access to component" do
  #       before do
  #         logmein @registeredUser
  #       end
  #       after do
  #         logmeout
  #       end
  #       it_behaves_like "a user-forbidden component"
  #     end
  #     context "user is logged and does have read access to component" do
  #       before do
  #         logmein @repositoryReader
  #       end
  #       after do
  #         logmeout
  #       end
  #       it_behaves_like "a user-accessible component"
  #     end
  #   end
  # end # show

  describe "update" do
    before do
      @component = Component.new
      @component.admin_policy = @publicReadAdminPolicy
      @component.save!
    end
    after do
      @component.delete
    end
    shared_examples_for "a user-editable component" do
      before do
        @component.edit_users = [@repositoryEditor.email]
        @component.save
        @item = Item.create
      end
      after do
        @component.edit_users = []
        @component.save
        @item.delete
      end
      it "should be able the associate the component with an item" do
        pending "move component-item association to separate page"
        visit component_path(@component)
        fill_in "Container", :with => @item.pid
        click_button "Add Component to Item"
        component = Component.find(@component.pid)
        component.container.should_not be_nil
        component.container.pid.should eq(@item.pid)
        i = Item.find(@item.pid)
        i.parts.should_not be_empty
        i.part_ids.should include(@component.pid)
      end
      it "should be able to add content to the component" do # issue 35
        visit edit_component_path(@component)
        attach_file "Content File", @filepath
        click_button "Update Component"
        # page.should have_content "Content added"
        component = Component.find(@component.pid)
        component.content.size.should eq(File.size(@filepath))
      end      
    end
    shared_examples_for "an edit-forbidden component" do
      it "should display a Forbidden (403) response" do
        visit edit_component_path(@component)
        page.should have_content @forbiddenText
      end
    end
    context "user is logged in and has edit access to component" do
      before do
        logmein @repositoryEditor
      end
      after do
        logmeout
      end
      it_behaves_like "a user-editable component"
    end
  end # update

end

