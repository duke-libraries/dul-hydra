require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'

 shared_examples "an attached Attachment" do
   it "should be the first attachment of the object to which it is attached" do
     expect(object.attachments.first).to eq(attachment)
   end
   it "should be attached to the object" do
     expect(attachment.attached_to).to eq(object)
   end
 end

describe Attachment do

  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that has content"

  context "relationships" do
    let(:attachment) do
      FactoryGirl.build(:attachment_with_content) do |obj| 
        obj.save(validate: false)
      end
    end
    let(:object) { FactoryGirl.create(:test_model) }
    after do
      object.delete
      attachment.delete
    end
    context "#attached_to=" do
      before do
        attachment.attached_to = object
        attachment.save
      end
      it_behaves_like "an attached Attachment"
    end
    context "when added to an object's attachments" do
      before do
        object.attachments << attachment
        object.save
      end
      it_behaves_like "an attached Attachment"
    end
  end
  context "validations" do
    subject { described_class.new }
    before { subject.valid? }
    it "should have a title" do
      subject.errors.messages.should have_key(:title)
    end
    it "should have content" do
      subject.errors.messages.should have_key(:content)
    end
    it "should be attached to another object" do
      subject.errors.messages.should have_key(:attached_to)
    end
  end

end
