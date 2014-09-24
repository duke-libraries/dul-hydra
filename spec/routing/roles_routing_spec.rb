require 'spec_helper'

describe "the roles router", :type => :routing do
  it "should have all the RESTful routes" do
    expect(get: '/roles').to route_to(controller: 'roles', action: 'index')
    expect(get: '/roles/new').to route_to(controller: 'roles', action: 'new')
    expect(post: '/roles').to route_to(controller: 'roles', action: 'create')
    expect(get: '/roles/1').to route_to(controller: 'roles', action: 'show', id: '1')
    expect(get: '/roles/1/edit').to route_to(controller: 'roles', action: 'edit', id: '1')
    expect(patch: '/roles/1').to route_to(controller: 'roles', action: 'update', id: '1')
    expect(delete: '/roles/1').to route_to(controller: 'roles', action: 'destroy', id: '1')
  end
end
