require 'spec_helper'

RSpec.describe PublicationJob, type: :job do

  describe '.send_notification' do
    let(:email) { 'nobody@example.com' }
    let(:subject) { 'Test Email' }
    let(:message) { 'Text of test message' }
    it 'sends an email' do
      expect{ described_class.send_notification(email: email, subject: subject, message: message) }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '.publication_scope' do
    it 'returns the correct string' do
      expect(described_class.publication_scope(Collection.new)).to eq(I18n.t('dul_hydra.publication.scope.collection'))
      expect(described_class.publication_scope(Item.new)).to eq(I18n.t('dul_hydra.publication.scope.item'))
      expect(described_class.publication_scope(Component.new)).to eq(I18n.t('dul_hydra.publication.scope.component'))
    end
  end

end
