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
end
