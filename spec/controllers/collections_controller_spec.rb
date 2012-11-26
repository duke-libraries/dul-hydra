require 'spec_helper'

describe CollectionsController do

  before do
    @publicReadPermissions = [{:type=>"group", :access=>"read", :name=>"public"}]
    @restrictedReadPermissions = [{:type=>"group", :access=>"read", :name=>"repositoryReader"}]
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
  end

  after do
    @repositoryReader.delete
    @registeredUser.delete
    @restrictedReadAdminPolicy.delete
    @publicReadAdminPolicy.delete
  end

  describe "#index" do
    before do
      @collection1 = Collection.create(:pid => "collection:1")
      @collection2 = Collection.create(:pid => "collection:2")
    end
    after do
      @collection1.delete
      @collection2.delete
    end
    it "should display a list of all the collections" do
      get :index
      response.should be_successful
      assigns[:collections].should include(@collection1)
      assigns[:collections].should include(@collection2)
    end
  end

  describe "#new" do
    context "user is not logged in" do
      it "should respond with a 403 Forbidden" do
        get :new
        response.response_code.should == 403
      end
    end
    context "user is logged in" do
      before do
        sign_in @registeredUser
      end
      after do
        sign_out @registeredUser
      end
      it "should set a template collection" do
        get :new
        response.should be_successful
        assigns[:collection].should be_kind_of Collection
      end
    end
  end

  describe "#create" do
    before do
      @count = Collection.count
      @pid = "collection:1"
      @empty_string_pid = ""
      @do_not_use_pid = "__DO_NOT_USE__"
    end
    after do
      Collection.find_each { |c| c.delete }
    end
    context "user is not logged in" do
      it "should respond with a 403 Forbidden" do
        post :create, :collection=>{:pid=>@pid}
        response.response_code.should == 403
      end
    end
    context "user is logged in" do
      before do
        sign_in @registeredUser
      end
      after do
        sign_out @registeredUser
      end
      it "should create a collection with the provided PID" do
        post :create, :collection=>{:pid=>@pid}
        response.should redirect_to collection_path(@pid)
        Collection.count.should eq(@count + 1)
      end
      it "should create a collection with a system-assigned PID when given no PID" do
        post :create, :collection=>{}
        response.should be_redirect
        Collection.count.should eq(@count + 1)
      end
      it "should create a collection with a system-assigned PID when given an empty string as a PID" do
        post :create, :collection=>{:pid=>@empty_string_pid}
        response.should be_redirect
        Collection.count.should eq(@count + 1)
      end
      it "should create a collection with a system-assigned PID when given a do not use PID" do
        post :create, :collection=>{:pid=>@do_not_use_pid}
        response.should be_redirect
        Collection.count.should eq(@count + 1)
      end
    end
  end

  describe "#show" do
    before do
      @collection = Collection.new
      @collection.title = "Collection Title"
      @collection.identifier = "collectionIdentifier"      
    end
    after do
      @collection.delete
    end
    shared_examples_for "an accessible collection" do
        it "should present the collection" do
          get :show, :id=>@collection
          response.should be_success
          assigns[:collection].should == @collection
        end      
    end
    shared_examples_for "a forbidden collection" do
        it "should respond with Forbidden (403)" do
          get :show, :id=>@collection
          response.response_code.should == 403
        end      
    end
    context "publicly readable collection" do
      context "using rightsMetadata datastream" do
        before do
          @collection.permissions = @publicReadPermissions
          @collection.save!          
        end
        context "user is not logged in" do
          it_behaves_like "an accessible collection"
        end
        context "user is logged in" do
          before do
            sign_in @registeredUser
          end
          after do
            sign_out @registeredUser
          end
          it_behaves_like "an accessible collection"
        end
      end
      context "using admin policy object" do
        before do
          apo = AdminPolicy.find(@publicReadAdminPolicy.pid)
          @collection.admin_policy = apo
          @collection.save!
        end
        context "user is not logged in" do
          it_behaves_like "an accessible collection"
        end
        context "user is logged in" do
          before do
            sign_in @registeredUser
          end
          after do
            sign_out @registeredUser
          end
          it_behaves_like "an accessible collection"
        end
      end
    end
    context "restricted collection" do
      context "using rightsMetadata datastream" do
        before do
          @collection.permissions = @restrictedReadPermissions
          @collection.save!
        end
        context "user is not logged in" do
          it_behaves_like "a forbidden collection"
        end
        context "user is logged in but does not have read access to collection" do
          before do
            sign_in @registeredUser
          end
          after do
            sign_out @registeredUser
          end
          it_behaves_like "a forbidden collection"
        end
        context "user is logged in and does have read access to collection" do
          before do
            sign_in @repositoryReader
          end
          after do
            sign_out @repositoryReader
          end
          it_behaves_like "an accessible collection"
        end
      end
      context "using admin policy object" do
        before do
          apo = AdminPolicy.find(@restrictedReadAdminPolicy.pid)
          @collection.admin_policy = apo
          @collection.save!
        end
        context "user is not logged in" do
          it_behaves_like "a forbidden collection"
        end
        context "user is logged in but does not have read access to collection" do
          before do
            sign_in @registeredUser
          end
          after do
            sign_out @registeredUser
          end
          it_behaves_like "a forbidden collection"
        end
        context "user is logged in and does have read access to collection" do
          before do
            sign_in @repositoryReader
          end
          after do
            sign_out @repositoryReader
          end
          it_behaves_like "an accessible collection"
        end
      end
    end
  end
end