require 'spec_helper'

RSpec.configure do |c|
  # declare an exclusion filter
  c.filter_run_excluding :broken => true
end

describe CollectionsController do

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

  end #index
  
  describe "#new" do

    it "should set a template collection" do
      get :new
      response.should be_successful
      assigns[:collection].should be_kind_of Collection
    end

  end #new
  
  describe "#create" do

    after do
      Collection.find(@pid).delete
    end

    before do
      @count = Collection.count
      @pid = "collection:1"
    end

    it "should create a collection", :broken => true do
      post :create, :collection => {:pid => @pid}
      response.should redirect_to collections_path
      Collection.count.should eq(@count + 1)
    end

  end #create

end
