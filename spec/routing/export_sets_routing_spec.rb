require 'spec_helper'

describe "export sets routing", type: :routing, export_sets: true do
  describe "RESTful routes" do
    it "should have an index route" do
      @route = {controller: 'export_sets', action: 'index'}
      expect(:get => '/export_sets').to route_to(@route)
      expect(:get => export_sets_path).to route_to(@route)
    end
    it "should have a show route" do
      @route = {controller: 'export_sets', action: 'show', id: "1"}
      expect(:get => '/export_sets/1').to route_to(@route)
      expect(:get => export_set_path(1)).to route_to(@route)
    end
    it "should have a new route" do
      @route = {controller: 'export_sets', action: 'new'}
      expect(:get => '/export_sets/new').to route_to(@route)
      expect(:get => new_export_set_path).to route_to(@route)
    end
    it "should have a create route" do
      @route = {controller: 'export_sets', action: 'create'}
      expect(:post => '/export_sets').to route_to(@route)
      expect(:post => export_sets_path).to route_to(@route)
    end
    it "should have a edit route" do
      @route = {controller: 'export_sets', action: 'edit', id: "1"}
      expect(:get => '/export_sets/1/edit').to route_to(@route)
      expect(:get => edit_export_set_path(1)).to route_to(@route)
    end
    it "should have a update route" do
      @route = {controller: 'export_sets', action: 'update', id: "1"}
      expect(:put => '/export_sets/1').to route_to(@route)
      expect(:put => export_set_path(1)).to route_to(@route)
    end
    it "should have a destroy route" do
      @route = {controller: 'export_sets', action: 'destroy', id: "1"}
      expect(:delete => '/export_sets/1').to route_to(@route)
      expect(:delete => export_set_path(1)).to route_to(@route)
    end
  end
  describe "non-RESTful routes" do
    before do
      @route = {controller: 'export_sets', action: 'archive', id: '1'}
      @path = '/export_sets/1/archive'
    end
    it "should have a route for creating an archive" do
      expect(:patch => @path).to route_to(@route)
    end
    it "should have a route for downloading an archive" do
      expect(:get => @path).to route_to(@route)
    end
    it "should have a route for destroying an archive" do
      expect(:delete => @path).to route_to(@route)
    end
  end
end
