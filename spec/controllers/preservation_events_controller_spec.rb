require 'spec_helper'

describe PreservationEventsController do
  let(:user) { FactoryGirl.create(:user) }
  after(:all) { user.delete }
  before(:each) { sign_in user }
  after(:each) { sign_out user }  
  context "#index" do
    subject { get :index, :id => object }
    let(:object) { FactoryGirl.create(:test_content_with_fixity_check) }
    after { object.destroy } 
    it { should render_template(:index) }
  end
end
