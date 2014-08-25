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
        expect(AttachToable.new.can_have_attachments?).to be_truthy
        expect(ActiveFedora::Base.new.can_have_attachments?).to be_falsey
      end
    end
    describe "#has_attachments?" do
      let(:attach_toable) { AttachToable.new }
      before { attach_toable.attachments << Attachment.new }
      it "should return true if the object has Attachments, otherwise false" do
        expect(AttachToable.new).not_to have_attachments
        expect(ActiveFedora::Base.new).not_to have_attachments
        expect(attach_toable).to have_attachments
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
        expect(Childrenable.new.can_have_children?).to be_truthy
        expect(ActiveFedora::Base.new.can_have_children?).to be_falsey
      end
    end
    describe "#has_children?" do
      let(:childrenable) { Childrenable.new }
      before { childrenable.children << ActiveFedora::Base.new }
      it "should return true if object has children, otherwise false" do
        expect(Childrenable.new).not_to have_children
        expect(ActiveFedora::Base.new).not_to have_children
        expect(childrenable).to have_children
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
        expect(Thumbnailable.new.can_have_thumbnail?).to be_truthy
        expect(ActiveFedora::Base.new.can_have_thumbnail?).to be_falsey
      end
    end
    describe "#has_thumbnail?" do
      let(:thumbnailable) { Thumbnailable.new }
      before { allow(thumbnailable.datastreams[DulHydra::Datastreams::THUMBNAIL]).to receive(:has_content?).and_return(true) }
      it "should return true if object has a thumbnail, else false" do
        expect(thumbnailable).to have_thumbnail
        expect(Thumbnailable.new).not_to have_thumbnail
        expect(ActiveFedora::Base.new).not_to have_thumbnail
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
        expect(Contentable.new.can_have_content?).to be_truthy
        expect(ActiveFedora::Base.new.can_have_content?).to be_falsey
      end
    end
    describe "#has_content?" do
      let(:contentable) { Contentable.new }
      before { allow(contentable.datastreams[DulHydra::Datastreams::CONTENT]).to receive(:has_content?).and_return(true) }
      it "should return true if object has content, else false" do
        expect(contentable).to have_content
        expect(Contentable.new).not_to have_content
        expect(ActiveFedora::Base.new).not_to have_content
      end
    end
  end
end
