require 'spec_helper'

describe CatalogController do
  context "#show" do
    subject { get :show, :id => object }
    after { object.delete }
    let(:object) { FactoryGirl.create(:test_model) }
    it { should render_template(:show) }
  end
end
