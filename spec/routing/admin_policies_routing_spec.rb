require 'spec_helper'

describe "admin policies routing" do
  describe "RESTful routes" do
    it "should not have an :index route" do
      expect(:get => '/admin_policies').not_to be_routable
    end
    it "should not have a :show route" do
      expect(:get => '/admin_policies/duke:1').not_to be_routable
    end
    it "should have an :edit route" do
      @route = {controller: 'admin_policies', action: 'edit', id: 'duke:1'}
      expect(:get => '/admin_policies/duke:1/edit').to route_to(@route)
      expect(:get => edit_admin_policy_path('duke:1')).to route_to(@route)
    end    
    it "should have an :update route" do
      @route = {controller: 'admin_policies', action: 'update', id: 'duke:1'}
      expect(:put => '/admin_policies/duke:1').to route_to(@route)
      expect(:put => admin_policy_path('duke:1')).to route_to(@route)
    end    
    it "should not have a :new route" do
      expect(:get => '/admin_policies/new').not_to be_routable
    end
    it "should not have a :create route" do
      expect(:post => '/admin_policies').not_to be_routable
    end    
    it "should not have a :destroy route" do
      expect(:delete => '/admin_policies/duke:1').not_to be_routable
    end
  end
end
