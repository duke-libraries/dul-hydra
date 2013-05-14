require 'spec_helper'

describe ChildrenController do
  context "#index" do
    context "object does not have content metadata" do
      let(:object) { FactoryGirl.create(:test_parent) }
      after { object.delete }
      it "should redirect to the fcrepo_admin associations page" do
        get :index, :object_id => object
        response.should redirect_to(:controller => 'fcrepo_admin/associations', :action => 'show', :object_id => object, :id => 'children', :use_route => 'fcrepo_admin')
      end
    end
  end
end
