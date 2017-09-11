describe "export files routing", type: :routing do
  specify {
    expect(get: "/export_files").to route_to(controller: "export_files", action: "new")
  }
  specify {
    expect(post: "/export_files").to route_to(controller: "export_files", action: "create")
  }
end
