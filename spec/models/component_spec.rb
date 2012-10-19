require 'spec_helper'

describe Component do

  before do
    @pid = "component:1"
    @component = Component.create(:pid => @pid)
  end
 
  after do
    @component.delete
  end

  it "should have a DC datastream" do
    @component.datastreams["DC"].should_not be_nil
  end

  it "should have a RELS-EXT datastream" do 
    @component.datastreams["RELS-EXT"].should_not be_nil
  end
  
  it "should be able to retrieve the component" do
    c = Component.find(@pid)
    c.pid.should eq(@pid)
  end
  
end
