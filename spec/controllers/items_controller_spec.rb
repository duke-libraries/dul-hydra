require 'spec_helper'

describe ItemsController do

  describe "#new" do
    it "should set a template item" do
      get :new
      response.should be_successful
      assigns[:item].should be_kind_of Item
    end
  end  

  describe "#create" do
    before do
      @count = Item.count
      @pid = "item:1"
      @empty_string_pid = ""
      @do_not_use_pid = "__DO_NOT_USE__"
    end
    after do
      Item.find_each { |i| i.delete }
    end
    it "should create an item with the provided PID" do
      post :create, :item=>{:pid=>@pid}
      response.should redirect_to item_path(@pid)
      Item.count.should eq(@count + 1)
    end
    it "should create an item with a system-assigned PID when given no PID" do
      post :create, :item=>{}
      response.should be_redirect
      Item.count.should eq(@count + 1)
    end
    it "should create an item with a system-assigned PID when given an empty string as a PID" do
      post :create, :item=>{:pid=>@empty_string_pid}
      response.should be_redirect
      Item.count.should eq(@count + 1)
    end
    it "should create an item with a system-assigned PID when given a do not use PID" do
      post :create, :item=>{:pid=>@do_not_use_pid}
      response.should be_redirect
      Item.count.should eq(@count + 1)
    end
  end
end
