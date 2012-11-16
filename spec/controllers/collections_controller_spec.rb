require 'spec_helper'

describe CollectionsController do
  include Devise::TestHelpers
  
  before do
    @userA = User.create!(email:'user1@nowhere.org', password:'supersecretUserApassword')
    sign_in @userA
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
    it "should set a template collection" do
      get :new
      response.should be_successful
      assigns[:collection].should be_kind_of Collection
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
  
  describe "#show" do
    before do
      @collection = Collection.new
      @collection.title = "Collection Title"
      @collection.identifier = "collectionIdentifier"
      @collection.permissions = [{:type=>"group", :access=>"read", :name=>"repositoryReader"}]
      @collection.save!
    end
    after do
      Collection.find_each { |c| c.delete }
    end
    it "should present the requested collection" do
      get :show, :id=>@collection
      response.should be_successful
      assigns[:collection].should == @collection
    end
  end
end
