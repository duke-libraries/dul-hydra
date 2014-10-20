require 'spec_helper'

module Ddr
  module Models
    describe HasRoleAssignments, type: :model do
    
      before(:all) do
        class RoleAssignable < ActiveFedora::Base
          include HasRoleAssignments
        end
      end

      subject { RoleAssignable.new }

      describe "#principal_has_role?" do
        it "should respond when given a list of principals and a valid role" do
          expect { subject.principal_has_role?(["bob", "admins"], :administrator) }.not_to raise_error
        end
        it "should respond when given a principal name and a valid role" do
          expect { subject.principal_has_role?("bob", :administrator) }.not_to raise_error
        end
        it "should raise an error when given an invalid role" do
          expect { subject.principal_has_role?("bob", :foo) }.to raise_error
        end
      end

    end
  end
end
