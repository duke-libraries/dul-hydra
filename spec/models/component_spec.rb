require 'spec_helper'

describe Component do
  before do
    @pid = "test:1"
  end
  
  it "should retrieve a component" do
    c = Component.find(@pid)
    c.pid.should == @pid
  end
end
