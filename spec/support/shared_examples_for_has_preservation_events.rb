require 'spec_helper'
require 'support/shared_examples_for_preservation_events'

shared_examples "an object that has preservation events" do

  context "#new" do
    subject { described_class.new }
    its(:preservation_events) { should be_kind_of(ActiveRecord::Relation) }
    its(:fixity_checks) { should be_kind_of(ActiveRecord::Relation) }
  end

  context "#fixity_check" do
    subject { obj.fixity_check }
    after { obj.delete }
    let(:obj) { described_class.create(title: 'I can be fixity-checked') }
    it_should_behave_like "a fixity check success preservation event"
  end

  context "#fixity_check!" do
    subject { obj.fixity_check! }
    after { obj.destroy }
    let(:obj) { described_class.create(title: 'I can be fixity-checked!') }
    it_should_behave_like "a fixity check success preservation event"
  end  

end
