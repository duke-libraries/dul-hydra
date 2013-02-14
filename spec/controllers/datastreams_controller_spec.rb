require 'spec_helper'

describe DatastreamsController do
  context "#index" do
    subject { get :index, :object_id => object }
    let(:object) { FactoryGirl.create(:collection_public_read) }
    after { object.delete }
    it { should render_template('datastreams/index') }
  end
  context "#show" do
    subject { get :show, :object_id => object, :id => dsid }
    let(:object) { FactoryGirl.create(:collection_public_read) }
    let(:dsid) { "DC" }
    after { object.delete }
    it { should render_template('datastreams/show') }
  end
end
