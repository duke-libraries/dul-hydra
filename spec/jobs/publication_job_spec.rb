require 'spec_helper'

RSpec.describe PublicationJob, type: :job do

  describe '.publication_scope' do
    it 'returns the correct string' do
      expect(described_class.publication_scope(Collection.new)).to eq(I18n.t('dul_hydra.publication.scope.collection'))
      expect(described_class.publication_scope(Item.new)).to eq(I18n.t('dul_hydra.publication.scope.item'))
      expect(described_class.publication_scope(Component.new)).to eq(I18n.t('dul_hydra.publication.scope.component'))
    end
  end

end
