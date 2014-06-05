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

  describe "thumbnail" do
    before do
      class Thumbnailable < ActiveFedora::Base
        include DulHydra::HasThumbnail
      end
    end
    after do
      Object.send(:remove_const, :Thumbnailable)
    end
    describe "#can_have_thumbnail?" do
      it "should return true if object can have a thumbnail, else false" do
        Thumbnailable.new.can_have_thumbnail?.should be_true
        ActiveFedora::Base.new.can_have_thumbnail?.should be_false
      end
    end
    describe "#has_thumbnail?" do
      let(:thumbnailable) { Thumbnailable.new }
      before { thumbnailable.datastreams[DulHydra::Datastreams::THUMBNAIL].stub(:has_content?).and_return(true) }
      it "should return true if object has a thumbnail, else false" do
        thumbnailable.should have_thumbnail
        Thumbnailable.new.should_not have_thumbnail
        ActiveFedora::Base.new.should_not have_thumbnail
      end
    end
  end

  describe "content" do
    before do
      class Contentable < ActiveFedora::Base
        include DulHydra::HasContent
      end
    end
    after do
      Object.send(:remove_const, :Contentable)
    end
    describe "#can_have_content?" do
      it "should return true if object can have content, else false" do
        Contentable.new.can_have_content?.should be_true
        ActiveFedora::Base.new.can_have_content?.should be_false
      end
    end
    describe "#has_content?" do
      let(:contentable) { Contentable.new }
      before { contentable.datastreams[DulHydra::Datastreams::CONTENT].stub(:has_content?).and_return(true) }
      it "should return true if object has content, else false" do
        contentable.should have_content
        Contentable.new.should_not have_content
        ActiveFedora::Base.new.should_not have_content
      end
    end
  end
end
