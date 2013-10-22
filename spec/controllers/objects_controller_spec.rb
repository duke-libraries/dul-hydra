require 'spec_helper'

describe ObjectsController do
  let(:object) { FactoryGirl.create(:test_model) }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  after(:all) { user.delete }
  after(:each) do
    object.delete
    sign_out user
  end
  context "#show" do
    it "should render the show template" do
      get :show, :id => object
      response.should render_template(:show)
    end
  end
  context "#edit" do
    it "should render the hydra-editor edit template" do
      controller.stub(:authorize!).with(:edit, object).and_return(true)
      get :edit, :id => object
      response.should render_template('records/edit')
    end
  end
  context "#update" do
    it "should redirect to the show page" do
      controller.stub(:authorize!).with(:update, object).and_return(true)
      put :update, :id => object, :test_model => {:title => "Updated"}
      response.should redirect_to(object_path(object))
    end
  end
end
