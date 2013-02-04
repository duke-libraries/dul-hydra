require 'spec_helper'
require 'support/shared_examples_for_preservation_events'

shared_examples "an object that has preservation events" do

  context "#new" do
    subject { described_class.new }
    its(:preservation_events) { should be_kind_of(Array) }
    its(:fixity_checks) { should be_kind_of(ActiveFedora::Relation) }
  end

  context "#validate_checksum" do
    subject { obj.validate_checksum("DC") }
    after { obj.delete }
    let(:obj) { described_class.create.reload }
    it_should_behave_like "a fixity check success preservation event"
  end

  context "#validate_checksum!" do
    subject { obj.validate_checksum!("DC") }
    after do
      preservation_events = obj.preservation_events
      obj.delete
      preservation_events.each { |e| e.delete }
    end
    let(:obj) { described_class.create.reload }
    it_should_behave_like "a fixity check success preservation event"
  end  

end
