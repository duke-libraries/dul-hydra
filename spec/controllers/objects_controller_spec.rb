require 'spec_helper'

describe ObjectsController do
  let(:object) { FactoryGirl.create(:test_model) }
  let(:user) { FactoryGirl.create(:user) }
  before do 
    sign_in user 
  end
  after(:all) { user.delete }
  after(:each) do
    object.delete
    sign_out user
  end
  context "#show" do
    it "should render the show template" do
      controller.current_ability.can(:read, SolrDocument) do |obj|
        obj.id == object.pid
      end
      get :show, :id => object
      response.should render_template(:show)
    end
  end
  context "#edit" do
    it "should render the hydra-editor edit template" do
      controller.current_ability.can(:edit, ActiveFedora::Base) do |obj|
        obj.pid == object.pid
      end
      get :edit, :id => object
      response.should render_template('records/edit')
    end
  end
  context "#update" do
    before do
      controller.current_ability.can(:update, ActiveFedora::Base) do |obj|
        obj.pid == object.pid
      end
      controller.stub(:current_object).and_return(object)
      put :update, :id => object, :test_model => {:title => "Updated"}
    end
    it "should redirect to the show page" do
      response.should redirect_to(record_path(object))
    end
    it "should update the object" do
      object.reload
      object.title.should == ["Updated"]
    end
  end
end
