require 'spec_helper'
require 'support/shared_examples_helpers'
require 'application_helper'

RSpec.configure do |c|
  c.include SharedExamplesHelpers
  c.include ApplicationHelper
end

shared_examples "a DulHydra object datastreams view" do |object_sym|
  subject { page }
  let(:obj) do
    o = FactoryGirl.create(object_sym)
    o.permissions = [{:access => 'read', :type => 'group', :name => 'public'}]
    o.save!
    o
  end
  before { visit object_datastreams_path(obj) }
  after { obj.delete }
  it "should have links to all datastreams" do
    obj.datastreams.each_key do |dsid|
      expect(subject).to have_link(dsid, :href => object_datastream_path(obj, dsid))
    end
  end

end
