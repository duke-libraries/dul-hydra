shared_examples "a repository object router" do
  it "should have a new route" do
    expect(get: "/#{controller}/new").to route_to(controller: controller, action: "new") unless controller == "targets"
  end
  it "should have a create route" do
    expect(post: "/#{controller}").to route_to(controller: controller, action: "create") unless controller == "targets"
  end
  it "should have a show route" do
    expect(get: "/#{controller}/duke:1").to route_to(controller: controller, action: "show", id: "duke:1")
  end
  it "should have an edit route" do
    expect(get: "/#{controller}/duke:1/edit").to route_to(controller: controller, action: "edit", id: "duke:1")
  end
  it "should have an update route" do
    expect(patch: "/#{controller}/duke:1").to route_to(controller: controller, action: "update", id: "duke:1")
  end
  it "should not have permissions routes" do
    expect(get: "/#{controller}/duke:1/permissions").to_not be_routable
    expect(patch: "/#{controller}/duke:1/permissions").to_not be_routable
  end
  it "should have roles routes" do
    expect(get: "/#{controller}/duke:1/roles").to route_to(controller: controller, action: "roles", id: "duke:1")
    expect(patch: "/#{controller}/duke:1/roles").to route_to(controller: controller, action: "roles", id: "duke:1")
  end
  it "should have an administrative metadata route" do
    expect(get: "/#{controller}/duke:1/admin_metadata").to route_to(controller: controller, action: "admin_metadata", id: "duke:1")
    expect(patch: "/#{controller}/duke:1/admin_metadata").to route_to(controller: controller, action: "admin_metadata", id: "duke:1")
  end
  it "should have an events route" do
    expect(get: "/#{controller}/duke:1/events").to route_to(controller: controller, action: "events", id: "duke:1")
  end
  it "should have an event route" do
    expect(get: "/#{controller}/duke:1/events/1").to route_to(controller: controller, action: "event", id: "duke:1", event_id: "1")
  end
end

shared_examples "a content-bearing object router" do
  it "should have a upload routes" do
    expect(get: "/#{controller}/duke:1/upload").to route_to(controller: controller, action: "upload", id: "duke:1")
    expect(patch: "/#{controller}/duke:1/upload").to route_to(controller: controller, action: "upload", id: "duke:1")
  end
end
