require 'spec_helper'

describe PreservationEventsController do
  context "#index" do
    subject { get :index, :id => object }
    let(:object) { FactoryGirl.create(:test_content_with_fixity_check) }
    after { object.destroy } 
    it { should render_template(:index) }
  end
end
