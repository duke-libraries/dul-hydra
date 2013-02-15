require 'spec_helper'
require 'support/shared_examples_for_dul_hydra_views'

describe 'collections/show.html.erb' do
  it_behaves_like "a DulHydra object show view" do
    subject { page }
    let(:obj) { FactoryGirl.create(:collection_has_item_has_apo) }
    before { visit item_path(obj) }
    after do
      obj.items.first.delete
      obj.admin_policy.delete
      obj.reload
      obj.delete
    end
  end
end
