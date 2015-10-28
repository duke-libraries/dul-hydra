shared_examples "a repository object router" do
  let(:id) { "bc/a8/30/13/bca83013-2c43-40e4-8779-add4b29fac2f" }
  let(:escaped_id) { "bc%2Fa8%2F30%2F13%2Fbca83013-2c43-40e4-8779-add4b29fac2f" }
  it "should have a show route" do
    expect(get: "/#{controller}/#{escaped_id}")
      .to route_to(controller: controller, action: "show", id: id)
  end
  it "should have an edit route" do
    expect(get: "/#{controller}/#{escaped_id}/edit")
      .to route_to(controller: controller, action: "edit", id: id)
  end
  it "should have an update route" do
    expect(patch: "/#{controller}/#{escaped_id}")
      .to route_to(controller: controller, action: "update", id: id)
  end
  it "should have roles routes" do
    expect(get: "/#{controller}/#{escaped_id}/roles")
      .to route_to(controller: controller, action: "roles", id: id)
    expect(patch: "/#{controller}/#{escaped_id}/roles")
      .to route_to(controller: controller, action: "roles", id: id)
  end
  it "should have an administrative metadata route" do
    expect(get: "/#{controller}/#{escaped_id}/admin_metadata")
      .to route_to(controller: controller, action: "admin_metadata", id: id)
    expect(patch: "/#{controller}/#{escaped_id}/admin_metadata")
      .to route_to(controller: controller, action: "admin_metadata", id: id)
  end
  it "should have an events route" do
    expect(get: "/#{controller}/#{escaped_id}/events")
      .to route_to(controller: controller, action: "events", id: id)
  end
  it "should have an event route" do
    expect(get: "/#{controller}/#{escaped_id}/events/1")
      .to route_to(controller: controller, action: "event", id: id, event_id: "1")
  end
end

shared_examples "a creatable object router" do
  it "should have a new route" do
    expect(get: "/#{controller}/new")
      .to route_to(controller: controller, action: "new")
  end
  it "should have a create route" do
    expect(post: "/#{controller}")
      .to route_to(controller: controller, action: "create")
  end
end

shared_examples "a content-bearing object router" do
  let(:id) { "bc/a8/30/13/bca83013-2c43-40e4-8779-add4b29fac2f" }
  let(:escaped_id) { "bc%2Fa8%2F30%2F13%2Fbca83013-2c43-40e4-8779-add4b29fac2f" }
  it "should have a upload routes" do
    expect(get: "/#{controller}/#{escaped_id}/upload")
      .to route_to(controller: controller, action: "upload", id: id)
    expect(patch: "/#{controller}/#{escaped_id}/upload")
      .to route_to(controller: controller, action: "upload", id: id)
  end
end
