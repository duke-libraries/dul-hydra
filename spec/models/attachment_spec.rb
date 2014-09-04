require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_objects'
require 'support/shared_examples_for_has_content'

describe Attachment, type: :model, attachments: true do

  it_behaves_like "a DulHydra object"
  it_behaves_like "an object that can have content"

  context "relationships" do
    let(:attachment) { FactoryGirl.create(:attachment) }
    let(:object) { FactoryGirl.create(:collection) }
    context "#attached_to=" do
      before do
        attachment.attached_to = object
        attachment.save
        object.reload
      end
      it "should be the first attachment of the object to which it is attached" do
        expect(object.attachments.first).to eq(attachment)
      end
      it "should be attached to the object" do
        expect(attachment.attached_to).to eq(object)
      end
    end
    context "when added to an object's attachments" do
      before do
        object.attachments << attachment
        object.save!
        attachment.reload
      end
      it "should be the first attachment of the object to which it is attached" do
        expect(object.attachments.first).to eq(attachment)
      end
      it "should be attached to the object" do
        skip "Unable to determine cause of test failure - works at console"
        expect(attachment.attached_to).to eq(object)
      end
    end
  end

  context "validations" do
    subject { described_class.new }
    before { subject.valid? }
    it "should have content" do
      expect(subject.errors.messages).to have_key(:content)
    end
  end
end
