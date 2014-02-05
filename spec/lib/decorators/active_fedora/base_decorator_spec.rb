require 'spec_helper'

describe ActiveFedora::Base do
  describe "attachments", attachments: true do
    before do
      class AttachToable < ActiveFedora::Base
        include DulHydra::HasAttachments
      end
    end
    after do
      Object.send(:remove_const, :AttachToable)
    end
    describe "#can_have_attachments?" do
      it "#should return true if the object can have attachments, otherwise false" do
        AttachToable.new.can_have_attachments?.should be_true
        ActiveFedora::Base.new.can_have_attachments?.should be_false
      end
    end
    describe "#has_attachments?" do
      let(:attach_toable) { AttachToable.new }
      before { attach_toable.attachments << Attachment.new }
      it "should return true if the object has Attachments, otherwise false" do
        AttachToable.new.should_not have_attachments
        ActiveFedora::Base.new.should_not have_attachments
        attach_toable.should have_attachments
      end
    end
  end
  describe "children", children: true do
    before do
      class Childrenable < ActiveFedora::Base
        has_many :children, property: :is_member_of, class_name: 'ActiveFedora::Base'
      end
    end
    after do
      Object.send(:remove_const, :Childrenable)
    end
    describe "#can_have_children?" do
      it "should return true if object can have children, otherwise false" do
        Childrenable.new.can_have_children?.should be_true
        ActiveFedora::Base.new.can_have_children?.should be_false
      end
    end
    describe "#has_children?" do
      let(:childrenable) { Childrenable.new }
      before { childrenable.children << ActiveFedora::Base.new }
      it "should return true if object has children, otherwise false" do
        Childrenable.new.should_not have_children
        ActiveFedora::Base.new.should_not have_children
        childrenable.should have_children
      end
    end
  end
  describe "preservation events", preservation_events: true do
    before do
      class PreservationEventable < ActiveFedora::Base
        include DulHydra::HasPreservationEvents
      end
    end
    after do
      Object.send(:remove_const, :PreservationEventable)
    end
    describe "#can_have_preservation_events?" do
      it "should return true if object can have preservation events, else false" do
        PreservationEventable.new.can_have_preservation_events?.should be_true
        ActiveFedora::Base.new.can_have_preservation_events?.should be_false        
      end
    end
    describe "#has_preservation_events?" do
      let(:preservation_eventable) { PreservationEventable.create }
      before { PreservationEvent.creation!(preservation_eventable) }
      after { preservation_eventable.destroy }
      it "should return true if object has preservation events, else false" do
        preservation_eventable.should have_preservation_events
        PreservationEventable.new.should_not have_preservation_events
        ActiveFedora::Base.new.should_not have_preservation_events
      end
    end
  end
end
