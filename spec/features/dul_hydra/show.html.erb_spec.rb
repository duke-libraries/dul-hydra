require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe 'dul_hydra/show.html.erb' do
  subject { page }
  after { obj.delete }
  it_behaves_like "a DulHydra object show view" do
    let(:obj) { FactoryGirl.create(:component_part_of_item_has_apo) }
    before { visit component_path(obj) }
  end
  it_behaves_like "a DulHydra object show view" do
    let(:obj) { FactoryGirl.create(:item_in_collection_has_part_has_apo) }
    before { visit item_path(obj) }
  end
  it_behaves_like "a DulHydra object show view" do
    let(:obj) { FactoryGirl.create(:collection_has_item_has_apo) }
    before { visit collection_path(obj) }
  end
end
