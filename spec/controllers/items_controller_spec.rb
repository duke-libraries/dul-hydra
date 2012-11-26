require 'spec_helper'

describe ItemsController do

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
        assigns[:item].should be_kind_of Item
      end
    end
  end  

  describe "#create" do
    before do
      @count = Item.count
      @pid = "item:1"
      @empty_string_pid = ""
      @do_not_use_pid = "__DO_NOT_USE__"
    end
    after do
      Item.find_each { |i| i.delete }
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
      it "should create an item with the provided PID" do
        post :create, :item=>{:pid=>@pid}
        response.should redirect_to item_path(@pid)
        Item.count.should eq(@count + 1)
      end
      it "should create an item with a system-assigned PID when given no PID" do
        post :create, :item=>{}
        response.should be_redirect
        Item.count.should eq(@count + 1)
      end
      it "should create an item with a system-assigned PID when given an empty string as a PID" do
        post :create, :item=>{:pid=>@empty_string_pid}
        response.should be_redirect
        Item.count.should eq(@count + 1)
      end
      it "should create an item with a system-assigned PID when given a do not use PID" do
        post :create, :item=>{:pid=>@do_not_use_pid}
        response.should be_redirect
        Item.count.should eq(@count + 1)
      end
    end
  end
end
