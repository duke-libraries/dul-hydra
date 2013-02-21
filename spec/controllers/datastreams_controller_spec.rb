require 'spec_helper'

shared_examples "a datastream profile view" do
  it { should render_template(:show) }
end

describe DatastreamsController do
  context "#show" do
    let(:object) { FactoryGirl.create(:test_model) }
    let(:dsid) { "DC" }
    after { object.delete }
    context "profile information" do
      subject { get :show, :object_id => object, :id => dsid }
      it { should render_template(:show) }
    end
    context "download content" do
      subject { get :show, :object_id => object, :id => dsid, :download => 'true' }
      # XXX more specific expectation
      it { should be_successful }
    end
  end
end