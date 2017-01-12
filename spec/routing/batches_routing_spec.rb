require 'spec_helper'

describe "batches routing", type: :routing, batch: true do
  describe "RESTful routes" do
    it "has an index route" do
      @route = {controller: 'batches', action: 'index'}
      expect(:get => '/batches').to route_to(@route)
      expect(:get => batches_path).to route_to(@route)
    end
    it "has a show route" do
      @route = {controller: 'batches', action: 'show', id: "1"}
      expect(:get => '/batches/1').to route_to(@route)
      expect(:get => batch_path(1)).to route_to(@route)
    end
    it "has a destroy route" do
      @route = {controller: 'batches', action: 'destroy', id: "1"}
      expect(:delete => '/batches/1').to route_to(@route)
      expect(:delete => batch_path(1)).to route_to(@route)
    end
  end
  describe "non-RESTful routes" do
    it "has a route for validating a batch" do
      @route = {controller: 'batches', action: 'validate', id: '1'}
      expect(:get => 'batches/1/validate').to route_to(@route)
    end
    it "has a route for processing a batch" do
      @route = {controller: 'batches', action: 'procezz', id: '1'}
      expect(:get => 'batches/1/procezz').to route_to(@route)
    end
    it "has a route for 'my batches'" do
      @route = {controller: 'batches', action: 'index', filter: 'current_user'}
      expect(get: 'my_batches').to route_to(@route)
      expect(get: my_batches_path).to route_to(@route)
    end
  end
end
