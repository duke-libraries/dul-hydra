require 'spec_helper'

shared_examples "an object that has preservation events" do
  context "new" do
    subject { described_class.new }
    its(:preservation_events) { should be_kind_of(Array) }
  end
end
