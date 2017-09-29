require 'spec_helper'

RSpec.describe PublishJob, type: :job do

  describe ".perform" do
    let!(:obj) { double(id: 'test-1', class: Collection, publish!: nil) }
    let(:email) { 'test@example.com' }
    let(:expected_msg) { "Publication of #{obj.id} (#{I18n.t('dul_hydra.publication.scope.collection')}) has completed." }
    before do
      allow(ActiveFedora::Base).to receive(:find).with(obj.id) { obj }
    end
    it "should call 'publish!' on the object" do
      expect(obj).to receive(:publish!)
      described_class.perform('test-1', email)
    end
    it "should generate an email" do
      expect(JobMailer).to receive(:basic).with(to: email,
                                                subject: 'Publication Job COMPLETED',
                                                message: expected_msg)
      described_class.perform('test-1', email)
    end
  end

end
