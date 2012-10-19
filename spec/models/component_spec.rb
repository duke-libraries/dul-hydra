require 'spec_helper'

describe Component do

  before do
    @pid = "test:1"
    c = Component.new(:pid => @pid)
    c.save!
  end
 
  after do
    Component.find(@pid).delete
  end
  
  it "should retrieve the component" do
    c = Component.find(@pid)
    c.pid.should eq(@pid)
    c.datastreams.should have_key("DC")
    c.datastreams.should have_key("RELS-EXT")
  end
  
end
