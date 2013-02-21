require 'spec_helper'

describe AuditTrailController do
  context "#index" do
    subject { get :index, :object_id => object }
    let(:object) { FactoryGirl.create(:test_model) }
    after { object.delete }
    it { should render_template(:index) } 
  end
  context "#index?download=true" do
    subject { get :index, :object_id => object, :download => 'true' }
    let(:object) { FactoryGirl.create(:test_model) }
    after { object.delete }
    it { should be_successful }
  end
end
