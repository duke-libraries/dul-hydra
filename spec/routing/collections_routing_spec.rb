require 'spec_helper'
require 'support/shared_examples_for_repository_routers'

describe "collections router", type: :routing, collections: true do
  let(:controller) { "collections" }

  let(:id) { "bc/a8/30/13/bca83013-2c43-40e4-8779-add4b29fac2f" }
  let(:escaped_id) { "bc%2Fa8%2F30%2F13%2Fbca83013-2c43-40e4-8779-add4b29fac2f" }

  include_examples "a repository object router"
  include_examples "a creatable object router"

  it "should have an items route" do
    expect(get: "/collections/#{escaped_id}/items")
      .to route_to(controller: "collections", action: "items", id: id)
  end
  it "should have an attachments route" do
    expect(get: "/collections/#{escaped_id}/attachments")
      .to route_to(controller: "collections", action: "attachments", id: id)
  end
  it "should have a targets route" do
    expect(get: "/collections/#{escaped_id}/targets")
      .to route_to(controller: "collections", action: "targets", id: id)
  end
  it "should have a report route" do
    expect(get: "/collections/#{escaped_id}/report.csv")
      .to route_to(controller: "collections", action: "report", id: id, format: "csv")
  end
end
