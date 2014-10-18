require 'spec_helper'

module Ddr
  module Datastreams
    describe RoleAssignmentsDatastream do

      subject { described_class.new(nil) }

      describe "#principal_has_role?" do
        before do
          subject.administrator = ["bob", "sally"]
        end
        it "should accept a single principal" do
          expect(subject.principal_has_role?("sally", :administrator)).to be true
          expect(subject.principal_has_role?("fred", :administrator)).to be false
        end
        it "should accept a list of principals and return if at least one of the principals has the role" do
          expect(subject.principal_has_role?(["sally", "fred"], :administrator)).to be true
          expect(subject.principal_has_role?(["wendy", "fred"], :administrator)).to be false
        end
      end

    end
  end
end
