require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "collections router", type: :routing, collections: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "collections" }
  end
  it "should have an items route" do
    expect(get: "/collections/duke:1/items").to route_to(controller: "collections", action: "items", id: "duke:1")
  end
  it "should have an attachments route" do
    expect(get: "/collections/duke:1/attachments").to route_to(controller: "collections", action: "attachments", id: "duke:1")
  end
  it "should have a targets route" do
    expect(get: "/collections/duke:1/targets").to route_to(controller: "collections", action: "targets", id: "duke:1")
  end
  it "should have a report route" do
    expect(get: "/collections/duke:1/report.csv").to route_to(controller: "collections", action: "report", id: "duke:1", format: "csv")
  end
end
