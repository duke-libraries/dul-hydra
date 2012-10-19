require 'spec_helper'

describe CollectionsController do

  describe "#index" do
    before do
      @collection1 = Collection.create(:pid => "test:1")
      @collection2 = Collection.create(:pid => "test:2")
    end
    it "should display a list of all the collections" do
      get :index
      response.should be_successful
      assigns[:collections].should == [@collection1, @collection2]
    end
    after do
      @collection1.delete
      @collection2.delete
    end
  end
end
