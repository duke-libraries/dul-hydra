require 'spec_helper'

RSpec.describe UnPublishJob, type: :job do

  describe ".perform" do
    let!(:obj) { double(id: 'test-1', class: Item, unpublish!: nil) }
    let(:email) { 'test@example.com' }
    let(:expected_msg) { "Un-Publication of #{obj.id} (#{I18n.t('dul_hydra.publication.scope.item')}) has completed." }
    before do
      allow(ActiveFedora::Base).to receive(:find).with(obj.id) { obj }
    end
    it "should call 'unpublish!' on the object" do
      expect(obj).to receive(:unpublish!)
      described_class.perform('test-1', email)
    end
    it "should generate an email" do
      expect(JobMailer).to receive(:basic).with(to: email,
                                                subject: 'Un-Publication Job COMPLETED',
                                                message: expected_msg).and_call_original
      described_class.perform('test-1', email)
    end
  end
end
