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
  it "should have permissions routes" do
    expect(get: "/#{controller}/duke:1/permissions").to route_to(controller: controller, action: "permissions", id: "duke:1")
    expect(patch: "/#{controller}/duke:1/permissions").to route_to(controller: controller, action: "permissions", id: "duke:1")
  end
  it "should have an events route" do
    expect(get: "/#{controller}/duke:1/events").to route_to(controller: controller, action: "events", id: "duke:1")
  end
  it "should have a thumbnail route" do
    expect(:get => "/thumbnail/duke:1").to route_to(controller: "thumbnail", action: "show", id: "duke:1")
  end
  it "should have datastream routes" do
    expect(:get => "/#{controller}/duke:1/datastreams/descMetadata").to route_to(controller: "downloads", action: "show", id: "duke:1", datastream_id: "descMetadata")
  end
end

shared_examples "a content-bearing object router" do
  it "should have a download route" do
    expect(get: "/#{controller}/duke:1/download").to route_to(controller: "downloads", action: "show", id: "duke:1")
  end
  it "should have a upload routes" do
    expect(get: "/#{controller}/duke:1/upload").to route_to(controller: controller, action: "upload", id: "duke:1")
    expect(patch: "/#{controller}/duke:1/upload").to route_to(controller: controller, action: "upload", id: "duke:1")
  end
end
