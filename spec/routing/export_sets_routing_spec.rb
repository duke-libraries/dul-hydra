require 'spec_helper'

describe "export sets routing" do
  describe "RESTful routes" do
    it "should have an index route"
    it "should have a show route" do
      @route = {controller: 'export_sets', action: 'show', id: "1"}
      expect(:get => '/export_sets/1').to route_to(@route)
      expect(:get => export_set_path(1)).to route_to(@route)
    end
    it "should have a new route"
    it "should have a create route"
    it "should have a edit route"
    it "should have a update route"
    it "should have a destroy route"
  end
end
