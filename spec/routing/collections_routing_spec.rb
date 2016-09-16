require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "collections router", type: :routing, collections: true do
  it_behaves_like "a repository object router" do
    let(:controller) { "collections" }
  end
  it "has an items route" do
    expect(get: "/collections/duke:1/items").to route_to(controller: "collections", action: "items", id: "duke:1")
  end
  it "has an attachments route" do
    expect(get: "/collections/duke:1/attachments").to route_to(controller: "collections", action: "attachments", id: "duke:1")
  end
  it "has a targets route" do
    expect(get: "/collections/duke:1/targets").to route_to(controller: "collections", action: "targets", id: "duke:1")
  end
  it "has an export route" do
    expect(post: "/collections/duke:1/export.csv", type: "techmd").to route_to(controller: "collections", action: "export", id: "duke:1", format: "csv")
    expect(get: "/collections/duke:1/export").to route_to(controller: "collections", action: "export", id: "duke:1")
  end
end
