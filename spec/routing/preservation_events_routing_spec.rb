require 'spec_helper'

describe "preservation events routing" do
  describe "RESTful routes" do
    it "should have a show route" do
      @route = {controller: 'preservation_events', action: 'show', id: "1"}
      expect(:get => '/preservation_events/1').to route_to(@route)
      expect(:get => preservation_event_path(1)).to route_to(@route)
    end
    it "should NOT have an index route" do
      expect(:get => '/preservation_events').not_to be_routable
    end
    it "should NOT have an edit route" do
      expect(:get => '/preservation_events/1/edit').not_to be_routable
    end
    it "should NOT have an update route" do
      expect(:put => '/preservation_events/1').not_to be_routable
    end
    it "should NOT have a new route" do
      expect(:get => '/preservation_events/new').not_to be_routable
    end
    it "should NOT have a create route" do
      expect(:post => '/preservation_events').not_to be_routable
    end
    it "should NOT have a destroy route" do
      expect(:delete => '/preservation_events/1').not_to be_routable
    end
  end
end
