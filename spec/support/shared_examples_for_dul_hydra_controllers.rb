require 'spec_helper'

shared_examples "a DulHydra controller #index action" do
  subject { get :index }
  it "should redirect to catalog#index"
end

shared_examples "a DulHydra controller #show action" do
  it "should redirect to catalog#show" do
    expect(subject).to redirect_to(:controller => :catalog, :action => :show, :id => object.pid)
  end
end
