require 'spec_helper'

describe "events routing", events: true do
  describe "RESTful routes" do
    it "should have a show route" do
      @route = {controller: 'events', action: 'show', id: "1"}
      expect(get: '/events/1').to route_to @route
      expect(get: event_path(1)).to route_to @route
    end
    it "should have an index route" do
      @route = {controller: 'events', action: 'index'}
      expect(get: '/events').to route_to @route
      expect(get: '/events', pid: 'duke:1').to route_to @route
      expect(get: events_path).to route_to @route
    end
    it "should NOT have an edit route" do
      expect(get: '/events/1/edit').not_to be_routable
    end
    it "should NOT have an update route" do
      expect(put: '/events/1').not_to be_routable
    end
    it "should NOT have a new route" do
      expect(get: '/events/new').not_to be_routable
    end
    it "should NOT have a create route" do
      expect(post: '/events').not_to be_routable
    end
    it "should NOT have a destroy route" do
      expect(delete: '/events/1').not_to be_routable
    end
  end
end
