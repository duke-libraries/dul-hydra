shared_examples "a repository object router" do
  let(:id) { "bc/a8/30/13/bca83013-2c43-40e4-8779-add4b29fac2f" }
  let(:escaped_id) { "bc%2Fa8%2F30%2F13%2Fbca83013-2c43-40e4-8779-add4b29fac2f" }
  specify {
    expect(get: "/#{controller}/#{escaped_id}")
      .to route_to(controller: controller, action: "show", id: id)
  }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/edit")
      .to route_to(controller: controller, action: "edit", id: id)
  }
  specify {
    expect(patch: "/#{controller}/#{escaped_id}")
      .to route_to(controller: controller, action: "update", id: id)
  }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/roles")
      .to route_to(controller: controller, action: "roles", id: id)
  }
  specify {
    expect(patch: "/#{controller}/#{escaped_id}/roles")
      .to route_to(controller: controller, action: "roles", id: id)
  }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/admin_metadata")
      .to route_to(controller: controller, action: "admin_metadata", id: id)
  }
  specify {
    expect(patch: "/#{controller}/#{escaped_id}/admin_metadata")
      .to route_to(controller: controller, action: "admin_metadata", id: id)
  }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/events")
      .to route_to(controller: controller, action: "events", id: id)
  }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/events/1")
      .to route_to(controller: controller, action: "event", id: id, event_id: "1")
  }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/versions")
      .to route_to(controller: controller, action: "versions", id: id)
  }
end

shared_examples "a creatable object router" do
  specify {
    expect(get: "/#{controller}/new")
      .to route_to(controller: controller, action: "new")
  }
  specify {
    expect(post: "/#{controller}")
      .to route_to(controller: controller, action: "create")
  }
end

shared_examples "a content-bearing object router" do
  let(:id) { "bc/a8/30/13/bca83013-2c43-40e4-8779-add4b29fac2f" }
  let(:escaped_id) { "bc%2Fa8%2F30%2F13%2Fbca83013-2c43-40e4-8779-add4b29fac2f" }
  specify {
    expect(get: "/#{controller}/#{escaped_id}/upload")
      .to route_to(controller: controller, action: "upload", id: id)
  }
  specify {
    expect(patch: "/#{controller}/#{escaped_id}/upload")
      .to route_to(controller: controller, action: "upload", id: id)
  }
end
